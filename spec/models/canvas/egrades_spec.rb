require "spec_helper"

describe Canvas::Egrades do
  let(:user_id)                   { 4868640 }
  let(:canvas_course_id)          { 1164764 }
  let(:canvas_course_section_id)  { 1312012 }
  subject { Canvas::Egrades.new(:user_id => user_id, :canvas_course_id => canvas_course_id) }

  let(:canvas_course_students_list) do
    [
      {:sis_login_id => "872584", :sis_user_id => "2004491", :final_score => 34.9, :final_grade => "F"},
      {:sis_login_id => "4000123", :sis_user_id => "UID:4000123", :final_score => 89.5, :final_grade => "B"},
      {:sis_login_id => "872527", :sis_user_id => "2004445", :final_score => 99.5, :final_grade => "A+"},
      {:sis_login_id => "872529", :sis_user_id => "2004421", :final_score => 69.6, :final_grade => "D-"},
    ]
  end

  context "when serving official student grades csv" do
    before { allow(subject).to receive(:official_student_grades).with('C', '2014', '7309').and_return(canvas_course_students_list) }
    it "returns information relevant to egrades csv export" do
      official_grades_csv_string = subject.official_student_grades_csv('C', '2014', '7309')
      expect(official_grades_csv_string).to be_an_instance_of String
      official_grades_csv = CSV.parse(official_grades_csv_string, {headers: true})
      expect(official_grades_csv.count).to eq 4
      official_grades_csv.each do |grade|
        expect(grade).to be_an_instance_of CSV::Row
        expect(grade['uid']).to be_an_instance_of String
        expect(grade['grade']).to be_an_instance_of String
        expect(grade['comment']).to be_an_instance_of String
      end
      expect(official_grades_csv[0]['uid']).to eq "872584"
      expect(official_grades_csv[0]['grade']).to eq "F"
      expect(official_grades_csv[0]['comment']).to eq ""

      expect(official_grades_csv[3]['uid']).to eq "872529"
      expect(official_grades_csv[3]['grade']).to eq "D-"
      expect(official_grades_csv[3]['comment']).to eq ""
    end
  end

  context "when serving official student grades" do
    let(:primary_section_enrollees) do
      [
        {"ldap_uid"=>"872584", "enroll_status"=>"E", "first_name"=>"Angela", "last_name"=>"Martin", "student_email_address"=>"amartin@berkeley.edu", "student_id"=>"2004491", "affiliations"=>"STUDENT-STATUS-EXPIRED"},
        {"ldap_uid"=>"872527", "enroll_status"=>"E", "first_name"=>"Kelly", "last_name"=>"Kapoor", "student_email_address"=>"kellylovesryan@berkeley.edu", "student_id"=>"2004445", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"872529", "enroll_status"=>"E", "first_name"=>"Darryl", "last_name"=>"Philbin", "student_email_address"=>"darrylp@berkeley.edu", "student_id"=>"2004421", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
      ]
    end

    before do
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with('7309', '2014', 'C').and_return(primary_section_enrollees)
      allow(subject).to receive(:canvas_course_students).and_return(canvas_course_students_list)
    end
    it "only provides grades for official enrollees in section specified" do
      result = subject.official_student_grades('C', '2014', '7309')
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0][:sis_login_id]).to eq "872584"
      expect(result[1][:sis_login_id]).to eq "872527"
      expect(result[2][:sis_login_id]).to eq "872529"
    end
  end

  context "when providing canvas course students" do
    it "returns canvas course students with grades" do
      result = subject.canvas_course_students
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 6
      # Student with Grade
      expect(result[0][:sis_login_id]).to eq "4000123"
      expect(result[0][:sis_user_id]).to eq "UID:4000123"
      expect(result[0][:final_score]).to eq 34.9
      expect(result[0][:final_grade]).to eq "F"
      # Teacher Enrollment
      expect(result[1][:sis_login_id]).to eq "4000169"
      expect(result[1][:final_score]).to eq nil
      expect(result[1][:final_grade]).to eq nil
      # Student with No Grade
      expect(result[2][:sis_login_id]).to eq "4000309"
      expect(result[2][:final_score]).to eq nil
      expect(result[2][:final_grade]).to eq nil
      # Student with Grade
      expect(result[3][:sis_login_id]).to eq "4000189"
      expect(result[3][:final_score]).to eq 89.9
      expect(result[3][:final_grade]).to eq "B+"
      # Student with Grade
      expect(result[4][:sis_login_id]).to eq "4000199"
      expect(result[4][:final_score]).to eq 69.5
      expect(result[4][:final_grade]).to eq "D-"
      # Student with Grade
      expect(result[5][:sis_login_id]).to eq "4000272"
      expect(result[5][:sis_user_id]).to eq "20629333"
      expect(result[5][:final_score]).to eq 10.5
      expect(result[5][:final_grade]).to eq "F-"
    end

    it "should not source data from cache" do
      expect(Canvas::CourseUsers).to_not receive(:fetch_from_cache)
      result = subject.canvas_course_students
    end
  end

  context "when extracting student grades from enrollments" do
    let(:student_enrollment) do
      {
        "type"=>"StudentEnrollment",
        "role"=>"StudentEnrollment",
        "grades"=>{
          "current_score"=>95.0,
          "final_score"=>95.0,
          "current_grade"=>"A",
          "final_grade"=>"A"
        }
      }
    end
    let(:waitlist_student_enrollment) { student_enrollment.merge({'role' => 'Waitlist Student'}) }
    let(:ta_enrollment) { {"type"=>"TaEnrollment", "role"=>"TaEnrollment"} }
    it "returns empty grade hash when enrollments are empty" do
      result = subject.student_grade([])
      expect(result).to be_an_instance_of Hash
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq nil
    end

    it "returns empty grade when no student enrollments with grade are present" do
      waitlist_student_enrollment.delete('grades')
      result = subject.student_grade([ta_enrollment, waitlist_student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq nil
    end

    it "returns blank grade score when not present" do
      student_enrollment['grades'].delete('final_score')
      result = subject.student_grade([student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:final_score]).to eq nil
      expect(result[:final_grade]).to eq "A"
    end

    it "returns blank letter grade when not present" do
      student_enrollment['grades'].delete('final_grade')
      result = subject.student_grade([student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:final_score]).to eq 95.0
      expect(result[:final_grade]).to eq nil
    end

    it "returns grade when student enrollment is present" do
      result = subject.student_grade([ta_enrollment, waitlist_student_enrollment, student_enrollment])
      expect(result).to be_an_instance_of Hash
      expect(result[:final_score]).to eq 95.0
      expect(result[:final_grade]).to eq "A"
    end
  end

  context "when providing indicator of grade types present" do
    let(:student_enrollments) do
      [
        {:canvas_course_id=>1164764, :canvas_user_id=>4862319, :sis_user_id=>"UID:4000123", :sis_login_id=>"4000123", :name=>"Ted Andrew Greenwald", :final_score=>34.9, :final_grade=>"F"},
        {:canvas_course_id=>1164764, :canvas_user_id=>4861899, :sis_user_id=>"UID:4000169", :sis_login_id=>"4000169", :name=>"Harold Arnold DACUS", :final_score=>nil, :final_grade=>nil},
        {:canvas_course_id=>1164764, :canvas_user_id=>4862320, :sis_user_id=>"UID:4000309", :sis_login_id=>"4000309", :name=>"Michael David Ward", :final_score=>nil, :final_grade=>nil},
        {:canvas_course_id=>1164764, :canvas_user_id=>4872048, :sis_user_id=>"UID:4000189", :sis_login_id=>"4000189", :name=>"Melissa W. Gafford", :final_score=>89.9, :final_grade=>"B+"},
        {:canvas_course_id=>1164764, :canvas_user_id=>4862328, :sis_user_id=>"UID:4000199", :sis_login_id=>"4000199", :name=>"Robert Vannatta", :final_score=>69.5, :final_grade=>"D-"},
        {:canvas_course_id=>1164764, :canvas_user_id=>4869114, :sis_user_id=>"20629333", :sis_login_id=>"4000272", :name=>"LAURA CLARICE EISENBERG", :final_score=>10.5, :final_grade=>"F-"}
      ]
    end
    before { allow(subject).to receive(:canvas_course_students).and_return(invariable_student_enrollments) }
    context "when number grades not present" do
      let(:invariable_student_enrollments) do
        student_enrollments.each do |enrollment|
          enrollment[:final_score] = nil
          enrollment[:final_grade] = nil
        end
        student_enrollments
      end
      it "indicates no number or letter grades" do
        result = subject.grade_types_present
        expect(result).to be_an_instance_of Hash
        expect(result[:number_grades_present]).to be_false
        expect(result[:letter_grades_present]).to be_false
      end
    end

    context "when letter grades not present" do
      let(:invariable_student_enrollments) do
        student_enrollments.each {|enrollment| enrollment[:final_grade] = nil }
        student_enrollments
      end
      it "indicates number grades, yet no letter grades are present" do
        result = subject.grade_types_present
        expect(result).to be_an_instance_of Hash
        expect(result[:number_grades_present]).to be_true
        expect(result[:letter_grades_present]).to be_false
      end
    end

    context "when letter and number grades present" do
      let(:invariable_student_enrollments) { student_enrollments }
      it "indicates letter and number grades as present" do
        result = subject.grade_types_present
        expect(result).to be_an_instance_of Hash
        expect(result[:number_grades_present]).to be_true
        expect(result[:letter_grades_present]).to be_true
      end
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
      allow(subject).to receive(:official_section_identifiers).and_return(section_identifiers)
      allow(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2014', 'C', ['22280','22345']).and_return(sections)
    end
    context "when official sections are not identified in course site" do
      let(:section_identifiers) { [] }
      it "returns empty array" do
        expect(subject.official_sections).to eq []
      end
    end
    context "when official sections are identified in course site" do
      let(:section_identifiers) { [{:term_yr => '2014', :term_cd => 'C', :ccn => '22280'}, {:term_yr => '2014', :term_cd => 'C', :ccn => '22345'}] }
      it "provides array of filtered section hashes" do
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
            expect(section.include?(filtered_out_key)).to be_false
          end
        end
      end

      it "includes display name in each hash" do
        result = subject.official_sections
        expect(result).to be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to be_an_instance_of Hash
        expect(result[1]).to be_an_instance_of Hash
        expect(result[0]['display_name']).to eq "CHEM 3BL LEC 001"
        expect(result[1]['display_name']).to eq "CHEM 3BL LAB 208"
      end
    end
  end

  context "when providing official section terms existing within course" do
    let(:section_identifiers) {[
      {:term_yr => '2014', :term_cd => 'C', :ccn => '1299'},
      {:term_yr => '2014', :term_cd => 'D', :ccn => '1028'}
    ]}
    before { allow(subject).to receive(:official_section_identifiers).and_return(section_identifiers) }
    it "it returns array of term hashes" do
      # Note: There should never be more than one term in a course site
      # This feature is intended for detecting an exceptional scenario
      result = subject.section_terms
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]).to be_an_instance_of Hash
      expect(result[1]).to be_an_instance_of Hash
      expect(result[0][:term_cd]).to eq 'C'
      expect(result[1][:term_cd]).to eq 'D'
      expect(result[0][:term_yr]).to eq '2014'
      expect(result[1][:term_yr]).to eq '2014'
    end
  end

  context "when providing official section identifiers existing within course" do
    let(:course_sections) { [{'sis_section_id' => 'SEC:2014-C-7309'}, {'sis_section_id' => 'SEC:2014-C-6211'}] }
    let(:failed_response) { double(status: 500, body: '') }
    let(:success_response) { double(status: 200, body: JSON.generate(course_sections))}
    subject { Canvas::Egrades.new(:user_id => user_id, :canvas_course_id => 767330) }

    context "when course sections request fails" do
      before { allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(failed_response) }
      it "returns empty array" do
        expect(subject.official_section_identifiers).to eq []
      end
    end

    context "when course sections request returns sections" do
      before { allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(success_response) }
      it "returns ccn and term for canvas course sections" do
        sis_section_ids = subject.official_section_identifiers
        expect(sis_section_ids).to be_an_instance_of Array
        expect(sis_section_ids.count).to eq 2
        expect(sis_section_ids[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(sis_section_ids[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
      end

      it "returns course sections if already obtained" do
        expect_any_instance_of(Canvas::CourseSections).to receive(:sections_list).once.and_return(success_response)
        result_1 = subject.official_section_identifiers
        expect(result_1).to be_an_instance_of Array
        expect(result_1.count).to eq 2
        expect(result_1[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(result_1[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})

        result_2 = subject.official_section_identifiers
        expect(result_2).to be_an_instance_of Array
        expect(result_2.count).to eq 2
        expect(result_2[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(result_2[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
      end

      context "when course sections returned includes invalid section ids" do
        let(:course_sections) { [{'sis_section_id' => 'SEC:2014-C-7309'}, {'sis_section_id' => nil}, {'sis_section_id' => 'SEC:2014-C-6211'}, {'sis_section_id' => '2014-C-3623'}] }
        it "filters out invalid section ids" do
          sis_section_ids = subject.official_section_identifiers
          expect(sis_section_ids).to be_an_instance_of Array
          expect(sis_section_ids.count).to eq 2
          expect(sis_section_ids[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
          expect(sis_section_ids[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
        end
      end

    end

  end

end
