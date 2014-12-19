require 'spec_helper'

describe Canvas::CourseProvision do
  let(:instructor_id) { rand(99999).to_s }
  let(:user_id) { rand(99999).to_s }
  let(:canvas_admin_id) { rand(99999).to_s }
  let(:canvas_course_id) { rand(999999).to_s }
  let(:course_hash) { {'name' => 'JAVA for Minecraft Development', 'course_code' => 'COMPSCI 15B - SLF 001', 'term' => {'sis_term_id' => 'TERM:2014-D', 'name' => 'Fall 2014'}} }
  let(:official_sections) { [{:term_yr=>'2013', :term_cd=>'C', :ccn=>'7309'}] }
  let(:superuser_id) { rand(99999).to_s }
  let(:teaching_semesters) {
    [
      {
        :name => 'Fall 2013',
        :slug => 'fall-2013',
        :classes => [
          {
            :course_code => 'ENGIN 7',
            :dept => 'ENGIN',
            :slug => 'engin-7',
            :title => 'Introduction to Computer Programming for Scientists and Engineers',
            :role => 'Instructor',
            :sections => [
              { :ccn => "#{rand(99999)}", :instruction_format => 'DIS', :is_primary_section => false, :section_label => 'DIS 102', :section_number => '102' }
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
            :course_code => 'ENGIN 7',
            :dept => 'ENGIN',
            :slug => 'engin-7',
            :title => 'Introduction to Computer Programming for Scientists and Engineers',
            :sections => [
              { :ccn => by_ccns[0], :instruction_format => 'LEC', :is_primary_section => true, :section_label => 'LEC 003', :section_number => '003' },
              { :ccn => by_ccns[1], :instruction_format => 'DIS', :is_primary_section => false, :section_label => 'DIS 103', :section_number => '103' }
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

  context 'when uid is not present' do
    subject { Canvas::CourseProvision.new(nil) }
    its(:user_authorized?) { should eq false }
    its(:user_admin?) { should eq false }
  end

  context 'when manging existing course sections' do
    context 'when not admin acting as a user' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(official_sections)
        allow_any_instance_of(Canvas::Course).to receive(:course).and_return(course_hash)
      end
      subject { Canvas::CourseProvision.new(uid, canvas_course_id: canvas_course_id) }
      context 'when an instructor' do
        let(:uid) { instructor_id }
        its(:user_authorized?) { should eq true }
        it 'should provide sections feed with canvas course info included' do
          feed = subject.get_feed
          expect(feed[:is_admin]).to eq false
          expect(feed[:admin_acting_as]).to be_nil
          expect(feed[:teachingSemesters]).to eq teaching_semesters
          expect(feed[:admin_semesters]).to be_nil
          expect(feed[:canvas_course]).to be_an_instance_of Hash
          expect(feed[:canvas_course][:officialSections]).to eq official_sections
        end
      end
    end
  end

  context 'when admin acting as a user' do
    subject { Canvas::CourseProvision.new(uid, admin_acting_as: instructor_id) }
    context 'when a mischiefmaker' do
      let(:uid) { user_id }
      its(:user_authorized?) { should be_falsey }
      its(:get_feed) { should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_truthy }
      it 'should find courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_truthy
        expect(feed[:admin_acting_as]).to eq instructor_id
        expect(feed[:teachingSemesters]).to eq teaching_semesters
      end
    end
    context 'when a superuser' do
      let(:uid) { superuser_id }
      its(:user_authorized?) { should be_truthy }
    end
  end

  context 'when not admin acting as a user' do
    subject { Canvas::CourseProvision.new(uid) }
    context 'when a normal user' do
      let(:uid) {user_id}
      its(:user_authorized?) { should be_truthy }
      it 'should have empty feed' do
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
      it 'should have courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to eq false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq teaching_semesters
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_truthy }
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
      its(:user_authorized?) { should be_falsey }
      its(:get_feed) { should be_nil }
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      its(:user_authorized?) { should be_truthy }
      it 'should find courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_truthy
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq by_ccns_course_list
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
    context 'when a superuser' do
      let(:uid) { superuser_id }
      its(:user_authorized?) { should be_truthy }
    end
  end

  describe '#create_course_site' do
    subject     { Canvas::CourseProvision.new(instructor_id) }
    let(:cpcs)  { double() }
    before do
      allow(cpcs).to receive(:background).and_return(cpcs)
      allow(cpcs).to receive(:save).and_return(true)
      allow(cpcs).to receive(:create_course_site).and_return(true)
      allow(cpcs).to receive(:job_id).and_return('canvas.courseprovision.1234.1383330151057')
      allow(Canvas::ProvideCourseSite).to receive(:new).and_return(cpcs)
    end

    it 'returns nil if instructor does not have access to CCNs' do
      expect(subject).to receive(:user_authorized?).and_return(false)
      expect(subject.create_course_site('Intro to Biomedicine', 'BIOENG 101 LEC', 'fall-2013', ['1136', '1204'])).to be_nil
    end

    it 'returns canvas course provision job id' do
      expect(subject).to receive(:user_authorized?).and_return(true)
      result = subject.create_course_site('Intro to Biomedicine', 'BIOENG 101 LEC', 'fall-2013', ['1136', '1204'])
      expect(result).to eq 'canvas.courseprovision.1234.1383330151057'
    end

    it 'saves state of job before sending to bg job queue' do
      expect(cpcs).to receive(:save).ordered.and_return(true)
      expect(cpcs).to receive(:background).ordered.and_return(cpcs)
      expect(cpcs).to receive(:job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      result = subject.create_course_site('Intro to Biomedicine', 'BIOENG 101 LEC', 'fall-2013', ['1136', '1204'])
    end
  end

  describe '#remove_sections' do
    subject { Canvas::CourseProvision.new(instructor_id, :canvas_course_id => canvas_course_id) }
    let(:sis_section_ids) { ['SEC:2014-D-16171', 'SEC:2014-D-16109', 'SEC:2014-D-10287'] }
    let(:cpcs)  { double() }
    before do
      allow(cpcs).to receive(:background).and_return(cpcs)
      allow(cpcs).to receive(:save).and_return(true)
      allow(cpcs).to receive(:remove_sections).and_return(true)
      allow(cpcs).to receive(:job_id).and_return('canvas.courseprovision.1234.1383330151057')
      allow(Canvas::ProvideCourseSite).to receive(:new).and_return(cpcs)
    end
    context 'when canvas_course_id not present' do
      subject { Canvas::CourseProvision.new(instructor_id) }
      it 'should raise an error' do
        expect { subject.remove_sections(sis_section_ids) }.to raise_error(RuntimeError, 'canvas_course_id option not present')
      end
    end

    it 'returns nil if user not authorized to remove sections' do
      expect(subject).to receive(:user_authorized?).and_return(false)
      expect(subject.remove_sections(sis_section_ids)).to be_nil
    end

    it 'returns canvas course provision job id' do
      expect(subject).to receive(:user_authorized?).and_return(true)
      result = subject.remove_sections(sis_section_ids)
      expect(result).to eq 'canvas.courseprovision.1234.1383330151057'
    end

    it 'saves state of job before sending to bg job queue' do
      expect(cpcs).to receive(:save).ordered.and_return(true)
      expect(cpcs).to receive(:background).ordered.and_return(cpcs)
      expect(cpcs).to receive(:job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      result = subject.remove_sections(sis_section_ids)
    end
  end

  describe '#add_sections' do
    subject { Canvas::CourseProvision.new(instructor_id, :canvas_course_id => canvas_course_id) }
    let(:ccns) { ['16171', '16109', '10287'] }
    let(:term_code) { 'D' }
    let(:term_year) { '2014' }
    let(:cpcs)  { double() }
    before do
      allow(cpcs).to receive(:background).and_return(cpcs)
      allow(cpcs).to receive(:save).and_return(true)
      allow(cpcs).to receive(:add_sections).and_return(true)
      allow(cpcs).to receive(:job_id).and_return('canvas.courseprovision.1234.1383330151057')
      allow(Canvas::ProvideCourseSite).to receive(:new).and_return(cpcs)
    end

    context 'when canvas_course_id not present' do
      subject { Canvas::CourseProvision.new(instructor_id) }
      it 'should raise an error' do
        expect { subject.add_sections(term_code, term_year, ccns) }.to raise_error(RuntimeError, 'canvas_course_id option not present')
      end
    end

    it 'returns nil if user not authorized to add sections' do
      expect(subject).to receive(:user_authorized?).and_return(false)
      expect(subject.add_sections(term_code, term_year, ccns)).to be_nil
    end

    it 'returns canvas course provision job id' do
      expect(subject).to receive(:user_authorized?).and_return(true)
      result = subject.add_sections(term_code, term_year, ccns)
      expect(result).to eq 'canvas.courseprovision.1234.1383330151057'
    end

    it 'saves state of job before sending to bg job queue' do
      expect(cpcs).to receive(:save).ordered.and_return(true)
      expect(cpcs).to receive(:background).ordered.and_return(cpcs)
      expect(cpcs).to receive(:job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      result = subject.add_sections(term_code, term_year, ccns)
    end
  end

  describe '#get_course_info' do
    context 'when canvas_course_id not present' do
      subject { Canvas::CourseProvision.new(instructor_id) }
      it 'should raise an error' do
        expect { subject.get_course_info }.to raise_error(RuntimeError, 'canvas_course_id option not present')
      end
    end
    context 'when managing sections for existing course site' do
      subject { Canvas::CourseProvision.new(instructor_id, canvas_course_id: canvas_course_id) }
      before do
        allow_any_instance_of(Canvas::Course).to receive(:course).and_return(course_hash)
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(official_sections)
      end

      it 'should return course information' do
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:canvasCourseId]).to eq canvas_course_id
        expect(result[:name]).to eq course_hash['name']
        expect(result[:courseCode]).to eq course_hash['course_code']
      end

      it 'should return course term' do
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:term]).to be_an_instance_of Hash
        expect(result[:term][:name]).to eq course_hash['term']['name']
        expect(result[:term][:term_yr]).to eq '2014'
        expect(result[:term][:term_cd]).to eq 'D'
      end

      it 'should return official sections' do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(official_sections)
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:officialSections]).to eq official_sections
      end
    end
  end

end
