require "spec_helper"

describe CanvasCourseProvision do
  let(:instructor_id) { rand(99999).to_s }
  let(:user_id) { rand(99999).to_s }
  let(:canvas_admin_id) { rand(99999).to_s }
  let(:superuser_id) { rand(99999).to_s }
  let(:teaching_semesters) {
    [
      {
        :name => 'Fall 2013',
        :slug => 'fall-2013',
        :classes => [
          {
            :course_number => "ENGIN 7",
            :dept => "ENGIN",
            :slug => "engin-7",
            :title => "Introduction to Computer Programming for Scientists and Engineers",
            :role => "Instructor",
            :sections => [
              { :ccn => "#{rand(99999)}", :instruction_format => "DIS", :is_primary_section => false, :section_label => "DIS 102", :section_number => "102" }
            ]
          }
        ]
      }
    ]
  }
  let(:current_terms) {
    [
      {
        name: 'Fall 2013',
        slug: 'fall-2013'
      },
      {
        name: 'Spring 2014',
        slug: 'spring-2014'
      }
    ]
  }
  let(:by_ccns) {[rand(99999).to_s, rand(99999).to_s]}
  let(:by_ccns_semester) {'spring-2014'}
  let(:by_ccns_course_list) {
    [
      {
        :name => 'Spring 2014',
        :slug => 'spring-2014',
        :classes => [
          {
            :course_number => "ENGIN 7",
            :dept => "ENGIN",
            :slug => "engin-7",
            :title => "Introduction to Computer Programming for Scientists and Engineers",
            :sections => [
              { :ccn => by_ccns[0], :instruction_format => "LEC", :is_primary_section => true, :section_label => "LEC 003", :section_number => "003" },
              { :ccn => by_ccns[1], :instruction_format => "DIS", :is_primary_section => false, :section_label => "DIS 103", :section_number => "103" }
            ]
          }
        ]
      }
    ]
  }
  before { UserAuth.stub(:is_superuser?) {|uid| uid == superuser_id} }
  before { CanvasAdminsProxy.any_instance.stub(:admin_user?) {|uid| uid == canvas_admin_id} }
  before { CanvasProvideCourseSite.stub(:new) do |uid|
    double(
      candidate_courses_list: (uid == instructor_id) ? teaching_semesters : [],
      current_terms: current_terms,
      courses_list_from_ccns: by_ccns_course_list
    )
  end }

  context 'when delegating' do
    subject {CanvasCourseProvision.new(uid, admin_acting_as: instructor_id)}
    context 'when a mischiefmaker' do
      let(:uid) {user_id}
      its(:user_authorized?) { should be_false }
      its(:get_feed) {should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) {canvas_admin_id}
      its(:user_authorized?) { should be_true }
      it "should find courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_true
        expect(feed[:admin_acting_as]).to eq instructor_id
        expect(feed[:teaching_semesters]).to eq teaching_semesters
      end
    end
    context 'when a superuser' do
      let(:uid) {superuser_id}
      its(:user_authorized?) { should be_true }
    end
  end

  context 'when not delegating' do
    subject {CanvasCourseProvision.new(uid)}
    context 'when a normal user' do
      let(:uid) {user_id}
      its(:user_authorized?) { should be_true }
      it "should have empty feed" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teaching_semesters]).to be_empty
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when an instructor' do
      let(:uid) {instructor_id}
      its(:user_authorized?) { should be_true }
      it "should have courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teaching_semesters]).to eq teaching_semesters
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when a Canvas admin' do
      let(:uid) {canvas_admin_id}
      its(:user_authorized?) { should be_true }
      it 'provides all available semesters' do
        feed = subject.get_feed
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
  end

  context 'when directly specifying CCNs' do
    subject {CanvasCourseProvision.new(uid, {
      admin_by_ccns: by_ccns,
      admin_term_slug: by_ccns_semester
    })}
    context 'when a mischiefmaker' do
      let(:uid) {user_id}
      its(:user_authorized?) { should be_false }
      its(:get_feed) {should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) {canvas_admin_id}
      its(:user_authorized?) { should be_true }
      it "should find courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_true
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teaching_semesters]).to eq by_ccns_course_list
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
    context 'when a superuser' do
      let(:uid) {superuser_id}
      its(:user_authorized?) { should be_true }
    end
  end

  describe "#create_course_site" do
    subject     { CanvasCourseProvision.new(instructor_id) }
    let(:cpcs)  { double() }
    before do
      cpcs.stub(:background).and_return(cpcs)
      cpcs.stub(:save).and_return(true)
      cpcs.stub(:create_course_site).and_return(true)
      cpcs.stub(:job_id).and_return('canvas.courseprovision.1234.1383330151057')
      CanvasProvideCourseSite.stub(:new).and_return(cpcs)
    end

    it "returns nil if instructor does not have access to CCNs" do
      subject.should_receive(:user_authorized?).and_return(false)
      subject.create_course_site("fall-2013", ["1136", "1204"]).should be_nil
    end

    it "returns canvas course provision job id" do
      subject.should_receive(:user_authorized?).and_return(true)
      result = subject.create_course_site("fall-2013", ["1136", "1204"])
      result.should == 'canvas.courseprovision.1234.1383330151057'
    end

    it "saves state of job before sending to bg job queue" do
      cpcs.should_receive(:save).ordered.and_return(true)
      cpcs.should_receive(:background).ordered.and_return(cpcs)
      cpcs.should_receive(:job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      result = subject.create_course_site("fall-2013", ["1136", "1204"])
    end
  end

end
