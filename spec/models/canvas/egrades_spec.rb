require "spec_helper"

describe Canvas::Egrades do
  let(:canvas_course_id)          { 1276293 }
  let(:canvas_course_section_id)  { 1312012 }
  subject { Canvas::Egrades.new(:canvas_course_id => canvas_course_id) }

  let(:official_student_grades_list) do
    [
      {:sis_login_id => "872584", :final_grade => "F", :current_grade => "C", :pnp_flag => "N", :student_id => "2004491"},
      {:sis_login_id => "4000123", :final_grade => "B", :current_grade => "B", :pnp_flag => "N", :student_id => "24000123"},
      {:sis_login_id => "872527", :final_grade => "A+", :current_grade => "A+", :pnp_flag => "Y", :student_id => "2004445"},
      {:sis_login_id => "872529", :final_grade => "D-", :current_grade => "C", :pnp_flag => "N", :student_id => "2004421"},
    ]
  end

  let(:canvas_course_student_grades_list) do
    [
      {:sis_login_id => "872584", :final_grade => "F", :current_grade => "C"},
      {:sis_login_id => "4000123", :final_grade => "B", :current_grade => "B"},
      {:sis_login_id => "872527", :final_grade => "A+", :current_grade => "A+"},
      {:sis_login_id => "872529", :final_grade => "D-", :current_grade => "C"},
    ]
  end

  let(:course_assignments) {
    [
      {
        'id' => 19082,
        'name' => 'Assignment 1',
        'muted' => false,
        'due_at' => "2015-05-12T19:40:00Z",
        'points_possible' => 100
      },
      {
        'id' => 19083,
        'name' => 'Assignment 2',
        'muted' => true,
        'due_at' => "2015-10-13T06:05:00Z",
        'points_possible' => 50
      },
      {
        'id' => 19084,
        'name' => 'Assignment 3',
        'muted' => false,
        'due_at' => nil,
        'points_possible' => 25
      },
    ]
  }

  it_should_behave_like 'a background job worker'

  context "when setting the course user page total" do
    context "when default grading scheme enable option specified" do
      subject { Canvas::Egrades.new(:canvas_course_id => canvas_course_id, :enable_grading_scheme => true) }
      it "sets total steps to reflect grading scheme step plus number of pages" do
        subject.background_job_initialize
        subject.set_course_user_page_total('5')
        subject.background_job_complete_step('step 1')
        report = subject.background_job_report
        expect(report[:percentComplete]).to eq 0.17
      end
    end
    it "sets total steps to number of pages specified" do
      subject.background_job_initialize
      subject.set_course_user_page_total('5')
      subject.background_job_complete_step('step 1')
      report = subject.background_job_report
      expect(report[:percentComplete]).to eq 0.2
    end
  end

  context "when serving official student grades csv" do
    before { allow(subject).to receive(:official_student_grades).with('C', '2014', '7309').and_return(official_student_grades_list) }
    it "raises error when called with invalid type argument" do
      expect { subject.official_student_grades_csv('C', '2014', '7309', 'finished') }.to raise_error(ArgumentError, 'type argument must be \'final\' or \'current\'')
    end

    it "returns current grades" do
      official_grades_csv_string = subject.official_student_grades_csv('C', '2014', '7309', 'current')
      expect(official_grades_csv_string).to be_an_instance_of String
      official_grades_csv = CSV.parse(official_grades_csv_string, {headers: true})
      expect(official_grades_csv.count).to eq 4
      official_grades_csv.each do |grade|
        expect(grade).to be_an_instance_of CSV::Row
        expect(grade['student_id']).to be_an_instance_of String
        expect(grade['grade']).to be_an_instance_of String
        expect(grade['comment']).to be_an_instance_of String
      end
      expect(official_grades_csv[0]['student_id']).to eq "2004491"
      expect(official_grades_csv[0]['grade']).to eq "C"
      expect(official_grades_csv[0]['comment']).to eq ""

      expect(official_grades_csv[2]['student_id']).to eq "2004445"
      expect(official_grades_csv[2]['grade']).to eq "A+"
      expect(official_grades_csv[2]['comment']).to eq "Opted for P/NP Grade"

      expect(official_grades_csv[3]['student_id']).to eq "2004421"
      expect(official_grades_csv[3]['grade']).to eq "C"
      expect(official_grades_csv[3]['comment']).to eq ""
    end

    it "returns final grades" do
      official_grades_csv_string = subject.official_student_grades_csv('C', '2014', '7309', 'final')
      expect(official_grades_csv_string).to be_an_instance_of String
      official_grades_csv = CSV.parse(official_grades_csv_string, {headers: true})
      expect(official_grades_csv.count).to eq 4
      official_grades_csv.each do |grade|
        expect(grade).to be_an_instance_of CSV::Row
        expect(grade['student_id']).to be_an_instance_of String
        expect(grade['grade']).to be_an_instance_of String
        expect(grade['comment']).to be_an_instance_of String
      end
      expect(official_grades_csv[0]['student_id']).to eq "2004491"
      expect(official_grades_csv[0]['grade']).to eq "F"
      expect(official_grades_csv[0]['comment']).to eq ""

      expect(official_grades_csv[2]['student_id']).to eq "2004445"
      expect(official_grades_csv[2]['grade']).to eq "A+"
      expect(official_grades_csv[2]['comment']).to eq "Opted for P/NP Grade"

      expect(official_grades_csv[3]['student_id']).to eq "2004421"
      expect(official_grades_csv[3]['grade']).to eq "D-"
      expect(official_grades_csv[3]['comment']).to eq ""
    end
  end

  context "when serving official student grades" do
    let(:primary_section_enrollees) do
      [
        {"ldap_uid"=>"872584", "enroll_status"=>"E", "pnp_flag" => "N", "first_name"=>"Angela", "last_name"=>"Martin", "student_email_address"=>"amartin@berkeley.edu", "student_id"=>"2004491", "affiliations"=>"STUDENT-STATUS-EXPIRED"},
        {"ldap_uid"=>"872527", "enroll_status"=>"E", "pnp_flag" => "N", "first_name"=>"Kelly", "last_name"=>"Kapoor", "student_email_address"=>"kellylovesryan@berkeley.edu", "student_id"=>"2004445", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"872529", "enroll_status"=>"E", "pnp_flag" => "Y", "first_name"=>"Darryl", "last_name"=>"Philbin", "student_email_address"=>"darrylp@berkeley.edu", "student_id"=>"2004421", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
      ]
    end

    before do
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with('7309', '2014', 'C').and_return(primary_section_enrollees)
      allow(subject).to receive(:canvas_course_student_grades).and_return(canvas_course_student_grades_list)
    end
    it "only provides grades for official enrollees in section specified" do
      result = subject.official_student_grades('C', '2014', '7309')
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0][:sis_login_id]).to eq "872584"
      expect(result[1][:sis_login_id]).to eq "872527"
      expect(result[2][:sis_login_id]).to eq "872529"
    end

    it "includes pass/no-pass indicator" do
      result = subject.official_student_grades('C', '2014', '7309')
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0][:pnp_flag]).to eq "N"
      expect(result[1][:pnp_flag]).to eq "N"
      expect(result[2][:pnp_flag]).to eq "Y"
    end

    it "includes student IDs" do
      result = subject.official_student_grades('C', '2014', '7309')
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0][:student_id]).to eq '2004491'
      expect(result[1][:student_id]).to eq '2004445'
      expect(result[2][:student_id]).to eq '2004421'
    end
  end

  context "when preparing downloads" do
    let(:course_settings) do
      {
        'grading_standard_enabled' => true,
        'grading_standard_id' => 0
      }
    end
    let(:course_details) {
      {'id' => 1121, 'name' => 'Just another course site'}
    }
    let(:muted_assignments) { [] }
    before do
      subject.background_job_initialize
      allow_any_instance_of(Canvas::CourseSettings).to receive(:settings).and_return(course_settings)
      allow_any_instance_of(Canvas::CourseAssignments).to receive(:muted_assignments).and_return(muted_assignments)
    end

    context "when course grading scheme is not enabled" do
      before do
        course_settings['grading_standard_enabled'] = false
        course_settings['grading_standard_id'] = nil
        allow_any_instance_of(Canvas::CourseSettings).to receive(:set_grading_scheme).and_return(course_details)
        allow(subject).to receive(:canvas_course_student_grades).with(true)
      end
      context "when grading scheme enable confirmed" do
        subject { Canvas::Egrades.new(:canvas_course_id => canvas_course_id, :enable_grading_scheme => true) }
        it "enables grading scheme" do
          expect_any_instance_of(Canvas::CourseSettings).to receive(:set_grading_scheme).and_return(course_details)
          subject.prepare_download
        end
        it "sets the total steps to 30 to temporarily ensure a low reported percentage complete" do
          expect(subject).to receive(:background_job_set_total_steps).with(30).and_return(nil)
          subject.prepare_download
        end
        it "completes the grading scheme enabling step" do
          expect(subject).to receive(:background_job_complete_step).with('Enabled default grading scheme')
          subject.prepare_download
        end
      end
      context "when grading scheme enable not confirmed" do
        it "raises bad request exception" do
          expect { subject.prepare_download }.to raise_error(Errors::BadRequestError, 'Enable Grading Scheme action not specified')
        end
      end
    end

    context 'when muted assignments are present for course site' do
      let(:muted_assignments) { [{'id' => 1, 'name' => 'Assignment 1', 'muted' => true}] }
      before do
        allow_any_instance_of(Canvas::CourseAssignments).to receive(:muted_assignments).and_return(muted_assignments)
      end
      context "when unmute assignments action specified" do
        subject { Canvas::Egrades.new(:canvas_course_id => canvas_course_id, :unmute_assignments => true) }
        it "unmutes assignments for course site" do
          expect(subject).to receive(:unmute_course_assignments).with(canvas_course_id)
          subject.prepare_download
        end
      end
      context "when unmute assignments action not specified" do
        it "raises bad request exception" do
          expect { subject.prepare_download }.to raise_error(Errors::BadRequestError, 'Unmute assignments action not specified')
        end
      end
    end

    it "preloads canvas course users in cache" do
      expect(subject).to receive(:canvas_course_student_grades).with(true)
      subject.prepare_download
    end
  end

  context "when providing canvas course student grades" do
    before { subject.background_job_initialize }
    it "returns canvas course student grades" do
      result = subject.canvas_course_student_grades
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 11

      # Student with Grade
      expect(result[0][:sis_login_id]).to eq "4000123"
      expect(result[0][:final_grade]).to eq "F"
      expect(result[0][:current_grade]).to eq "F"

      # Teacher Enrollment
      expect(result[1][:sis_login_id]).to eq "4000169"
      expect(result[1][:final_grade]).to eq nil
      expect(result[1][:current_grade]).to eq nil

      # Student with No Grade
      expect(result[2][:sis_login_id]).to eq "4000309"
      expect(result[2][:final_grade]).to eq nil
      expect(result[2][:current_grade]).to eq nil

      # Student with Grade
      expect(result[3][:sis_login_id]).to eq "4000189"
      expect(result[3][:final_grade]).to eq "B+"
      expect(result[3][:current_grade]).to eq "B+"

      # Student with Grade
      expect(result[4][:sis_login_id]).to eq "4000199"
      expect(result[4][:final_grade]).to eq "D-"
      expect(result[4][:current_grade]).to eq "C"

      # Student with Grade
      expect(result[5][:sis_login_id]).to eq "4000272"
      expect(result[5][:final_grade]).to eq "F-"
      expect(result[5][:current_grade]).to eq "F-"
    end

    it "should not source data from cache" do
      expect(Canvas::CourseUsers).to_not receive(:fetch_from_cache)
      result = subject.canvas_course_student_grades
    end

    it "should not specify forced cache write by default" do
      expect(Canvas::Egrades).to_not receive(:fetch_from_cache).with("course-students-#{canvas_course_id}", true)
      result = subject.canvas_course_student_grades
    end

    it "should specify forced cache write when specified" do
      expect(Canvas::Egrades).to receive(:fetch_from_cache).with("course-students-#{canvas_course_id}", true)
      result = subject.canvas_course_student_grades(true)
    end
  end

  context "when extracting student grades from enrollments" do
    let(:student_enrollment) do
      {
        "type"=>"StudentEnrollment",
        "role"=>"StudentEnrollment",
        "grades"=>{
          "current_score"=>96.5,
          "final_score"=>95.0,
          "current_grade"=>"A+",
          "final_grade"=>"A"
        }
      }
    end
    let(:waitlist_student_enrollment) { student_enrollment.merge({'role' => 'Waitlist Student'}) }
    let(:ta_enrollment) { {"type"=>"TaEnrollment", "role"=>"TaEnrollment"} }
    it "returns empty grade hash when enrollments are empty" do
      result = subject.student_grade([])
      expect(result).to be_an_instance_of Hash
      expect(result[:current_score]).to eq nil
      expect(result[:current_grade]).to eq nil
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq nil
    end

    it "returns empty grade when no student enrollments with grade are present" do
      waitlist_student_enrollment.delete('grades')
      result = subject.student_grade([ta_enrollment, waitlist_student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:current_score]).to eq nil
      expect(result[:current_grade]).to eq nil
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq nil
    end

    it "returns blank grade score when not present" do
      student_enrollment['grades'].delete('current_score')
      student_enrollment['grades'].delete('final_score')
      result = subject.student_grade([student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:current_score]).to eq nil
      expect(result[:current_grade]).to eq "A+"
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq "A"
    end

    it "returns blank letter grade when not present" do
      student_enrollment['grades'].delete('current_grade')
      student_enrollment['grades'].delete('final_grade')
      result = subject.student_grade([student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:current_score]).to eq 96.5
      expect(result[:current_grade]).to eq nil
      expect(result[:final_score]).to eq 95.0
      expect(result[:final_grade]).to eq nil
    end

    it "returns grade when student enrollment is present" do
      result = subject.student_grade([ta_enrollment, waitlist_student_enrollment, student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:current_score]).to eq 96.5
      expect(result[:current_grade]).to eq "A+"
      expect(result[:final_score]).to eq 95.0
      expect(result[:final_grade]).to eq "A"
    end
  end

  context "when providing official sections" do
    let(:sections) do
      [
        {
          "course_title"=>"Organic Chemistry Laboratory",
          "course_title_short"=>"ORGANIC CHEM LAB",
          "dept_name"=>"CHEM",
          "catalog_id"=>"3BL",
          "term_yr"=>"2014",
          "term_cd"=>"C",
          "course_cntl_num"=>"22280",
          "primary_secondary_cd"=>"P",
          "section_num"=>"001",
          "instruction_format"=>"LEC",
          "catalog_root"=>"3",
          "catalog_prefix"=>nil,
          "catalog_suffix_1"=>"B",
          "catalog_suffix_2"=>"L"
        },
        {
          "course_title"=>"Organic Chemistry Laboratory",
          "course_title_short"=>"ORGANIC CHEM LAB",
          "dept_name"=>"CHEM",
          "catalog_id"=>"3BL",
          "term_yr"=>"2014",
          "term_cd"=>"C",
          "course_cntl_num"=>"22345",
          "primary_secondary_cd"=>"S",
          "section_num"=>"208",
          "instruction_format"=>"LAB",
          "catalog_root"=>"3",
          "catalog_prefix"=>nil,
          "catalog_suffix_1"=>"B",
          "catalog_suffix_2"=>"L"
        }
      ]
    end

    before do
      allow_any_instance_of(Canvas::OfficialCourse).to receive(:official_section_identifiers).and_return(section_identifiers)
      allow(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2014', 'C', ['22280','22345']).and_return(sections)
    end
    context 'when official sections are not identified in course site' do
      let(:section_identifiers) { [] }
      it 'returns empty array' do
        expect(subject.official_sections).to eq []
      end
    end
    context 'when official sections are identified in course site' do
      let(:section_identifiers) { [{:term_yr => '2014', :term_cd => 'C', :ccn => '22280'}, {:term_yr => '2014', :term_cd => 'C', :ccn => '22345'}] }
      it 'provides array of filtered section hashes' do
        result = subject.official_sections
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to be_an_instance_of Hash
        expect(result[1]).to be_an_instance_of Hash
        expect(result[0]['course_cntl_num']).to eq "22280"
        expect(result[1]['course_cntl_num']).to eq "22345"
        expect(result[0]['section_num']).to eq "001"
        expect(result[1]['section_num']).to eq "208"
        expect(result[0]['instruction_format']).to eq "LEC"
        expect(result[1]['instruction_format']).to eq "LAB"
        expect(result[0]['primary_secondary_cd']).to eq "P"
        expect(result[1]['primary_secondary_cd']).to eq "S"
        filtered_out_keys = ['course_title', 'course_title_short', 'catalog_root', 'catalog_prefix', 'catalog_suffix_1', 'catalog_suffix_2']
        filtered_out_keys.each do |filtered_out_key|
          result.each do |section|
            expect(section).to_not include(filtered_out_key)
          end
        end
      end

      it 'includes display name in each hash' do
        result = subject.official_sections
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to be_an_instance_of Hash
        expect(result[1]).to be_an_instance_of Hash
        expect(result[0]['display_name']).to eq 'CHEM 3BL LEC 001'
        expect(result[1]['display_name']).to eq 'CHEM 3BL LAB 208'
      end
    end
  end

  context 'when providing muted assignments' do
    let(:muted_course_assignments) { [course_assignments[1]] }
    before { allow_any_instance_of(Canvas::CourseAssignments).to receive(:muted_assignments).and_return(muted_course_assignments) }

    it 'provides current muted assignments' do
      muted_assignments = subject.muted_assignments
      expect(muted_assignments).to be_an_instance_of Array
      expect(muted_assignments.count).to eq 1
      expect(muted_assignments[0]['name']).to eq 'Assignment 2'
      expect(muted_assignments[0]['points_possible']).to eq 50
    end

    it 'converts due at timestamp to display format' do
      muted_assignments = subject.muted_assignments
      expect(muted_assignments).to be_an_instance_of Array
      expect(muted_assignments[0]['due_at']).to eq "Oct 13, 2015 at 6:05am"
    end
  end

  context 'when unmuting all course assignments' do
    let(:muted_course_assignments) do
      course_assignments.collect {|assignment| assignment['muted'] = true; assignment}
    end
    it 'unmutes all muted assignments for the course specified' do
      allow_any_instance_of(Canvas::CourseAssignments).to receive(:muted_assignments).and_return(muted_course_assignments)
      expect_any_instance_of(Canvas::CourseAssignments).to receive(:unmute_assignment).exactly(1).times.with(19082)
      expect_any_instance_of(Canvas::CourseAssignments).to receive(:unmute_assignment).exactly(1).times.with(19083)
      expect_any_instance_of(Canvas::CourseAssignments).to receive(:unmute_assignment).exactly(1).times.with(19084)
      result = subject.unmute_course_assignments(canvas_course_id)
    end
  end

  context 'when providing course states for grade export validation' do
    let(:official_course_sections) do
      [
        {'dept_name'=>'CHEM', 'catalog_id'=>'3BL', 'term_yr'=>'2014', 'term_cd'=>'C', 'course_cntl_num'=>'22280', 'primary_secondary_cd'=>'P', 'section_num'=>'001', 'instruction_format'=>'LEC'},
        {'dept_name'=>'CHEM', 'catalog_id'=>'3BL', 'term_yr'=>'2014', 'term_cd'=>'C', 'course_cntl_num'=>'22345', 'primary_secondary_cd'=>'S', 'section_num'=>'208', 'instruction_format'=>'LAB'}
      ]
    end
    let(:course_settings) do
      {
        'grading_standard_enabled' => true,
        'grading_standard_id' => 0
      }
    end
    let(:muted_assignments) do
      [
        {'name' => 'Assignment 4', 'due_at' => 'Oct 13, 2015 at 8:30am', 'points_possible' => 25},
        {'name' => 'Assignment 7', 'due_at' => 'Oct 18, 2015 at 9:30am', 'points_possible' => 100},
      ]
    end
    let(:grade_types) { {:number_grades_present => true, :letter_grades_present => false} }
    let(:section_terms) { [{:term_cd => 'C', :term_yr => '2014'}, {:term_cd => 'D', :term_yr => '2015'}] }
    before do
      allow_any_instance_of(Canvas::CourseSettings).to receive(:settings).and_return(course_settings)
      allow_any_instance_of(Canvas::OfficialCourse).to receive(:section_terms).and_return(section_terms)
      allow(subject).to receive(:official_sections).and_return(official_course_sections)
      allow(subject).to receive(:grade_types_present).and_return(grade_types)
      allow(subject).to receive(:muted_assignments).and_return(muted_assignments)
    end

    it 'provides official course sections' do
      result = subject.export_options
      official_sections = result[:officialSections]
      expect(official_sections).to be_an_instance_of Array
      expect(official_sections.count).to eq 2
      expect(official_sections[0]['course_cntl_num']).to eq '22280'
      expect(official_sections[1]['course_cntl_num']).to eq '22345'
    end

    it 'provides grading standard enabled boolean' do
      export_options = subject.export_options
      expect(export_options[:gradingStandardEnabled]).to eq true
    end

    it 'provides official section terms existing within course' do
      export_options = subject.export_options
      section_terms = export_options[:sectionTerms]
      expect(section_terms.count).to eq 2
      expect(section_terms[0][:term_cd]).to eq 'C'
      expect(section_terms[0][:term_yr]).to eq '2014'
      expect(section_terms[1][:term_cd]).to eq 'D'
      expect(section_terms[1][:term_yr]).to eq '2015'
    end

    it 'provides muted assignments existing within course' do
      export_options = subject.export_options
      muted_assignments = export_options[:mutedAssignments]
      expect(muted_assignments.count).to eq 2
      expect(muted_assignments[0]['name']).to eq 'Assignment 4'
      expect(muted_assignments[1]['name']).to eq 'Assignment 7'
    end
  end

end

