require "spec_helper"

describe Canvas::CourseProvision do
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
            :course_code => "ENGIN 7",
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
            :course_code => "ENGIN 7",
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
  before do
    User::Auth.new_or_update_superuser!(superuser_id)
    allow_any_instance_of(Canvas::Admins).to receive(:admin_user?) {|uid| uid == canvas_admin_id }
    allow(Canvas::ProvideCourseSite).to receive(:new) do |uid|
      double(
        candidate_courses_list: (uid == instructor_id) ? teaching_semesters : [],
        current_terms: current_terms,
        courses_list_from_ccns: by_ccns_course_list
      )
    end
  end

  context "when uid is not present" do
    subject { Canvas::CourseProvision.new(nil) }
    its(:user_authorized?) { should eq false }
    its(:user_admin?) { should eq false }
  end

  context 'when admin acting as a user' do
    subject { Canvas::CourseProvision.new(uid, admin_acting_as: instructor_id) }
    context 'when a mischiefmaker' do
      let(:uid) { user_id }
      its(:user_authorized?) { should be_false }
      its(:get_feed) { should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_true }
      it "should find courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_true
        expect(feed[:admin_acting_as]).to eq instructor_id
        expect(feed[:teachingSemesters]).to eq teaching_semesters
      end
    end
    context 'when a superuser' do
      let(:uid) { superuser_id }
      its(:user_authorized?) { should be_true }
    end
  end

  context 'when not admin acting as a user' do
    subject { Canvas::CourseProvision.new(uid) }
    context 'when a normal user' do
      let(:uid) {user_id}
      its(:user_authorized?) { should be_true }
      it "should have empty feed" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to eq false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to be_empty
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when an instructor' do
      let(:uid) { instructor_id }
      its(:user_authorized?) { should eq true }
      it "should have courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to eq false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq teaching_semesters
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_true }
      it 'provides all available semesters' do
        feed = subject.get_feed
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
  end

  context 'when admin directly specifying CCNs' do
    subject { Canvas::CourseProvision.new(uid, admin_by_ccns: by_ccns, admin_term_slug: by_ccns_semester) }
    context 'when a mischiefmaker' do
      let(:uid) { user_id }
      its(:user_authorized?) { should be_false }
      its(:get_feed) { should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_true }
      it "should find courses" do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_true
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq by_ccns_course_list
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
    context 'when a superuser' do
      let(:uid) { superuser_id }
      its(:user_authorized?) { should be_true }
    end
  end

  describe "#create_course_site" do
    subject     { Canvas::CourseProvision.new(instructor_id) }
    let(:cpcs)  { double() }
    before do
      allow(cpcs).to receive(:background).and_return(cpcs)
      allow(cpcs).to receive(:save).and_return(true)
      allow(cpcs).to receive(:create_course_site).and_return(true)
      allow(cpcs).to receive(:job_id).and_return('canvas.courseprovision.1234.1383330151057')
      allow(Canvas::ProvideCourseSite).to receive(:new).and_return(cpcs)
    end

    it "returns nil if instructor does not have access to CCNs" do
      expect(subject).to receive(:user_authorized?).and_return(false)
      expect(subject.create_course_site("Intro to Biomedicine", "BIOENG 101 LEC", "fall-2013", ["1136", "1204"])).to be_nil
    end

    it "returns canvas course provision job id" do
      expect(subject).to receive(:user_authorized?).and_return(true)
      result = subject.create_course_site("Intro to Biomedicine", "BIOENG 101 LEC", "fall-2013", ["1136", "1204"])
      expect(result).to eq 'canvas.courseprovision.1234.1383330151057'
    end

    it "saves state of job before sending to bg job queue" do
      expect(cpcs).to receive(:save).ordered.and_return(true)
      expect(cpcs).to receive(:background).ordered.and_return(cpcs)
      expect(cpcs).to receive(:job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      result = subject.create_course_site("Intro to Biomedicine", "BIOENG 101 LEC", "fall-2013", ["1136", "1204"])
    end
  end

end
