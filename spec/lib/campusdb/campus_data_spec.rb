require "spec_helper"

describe CampusData do
  it "should find Oliver" do
    data = CampusData.get_person_attributes(2040)
    data['first_name'].should == "Oliver"
    if CampusData.test_data?
      data[:roles][:student].should == false
      data[:roles][:faculty].should == false
      data[:roles][:staff].should == true
    end
  end

  it "should find a user who has a bunch of blocks" do
    data = CampusData.get_person_attributes(300847)
    if CampusData.test_data?
      # we will only have predictable reg_status_cd values in our fake Oracle db.
      data['educ_level'].should == "Masters"
      data['admin_blk_flag'].should == "Y"
      data['acad_blk_flag'].should == "Y"
      data['fin_blk_flag'].should == "Y"
      data['reg_blk_flag'].should == "Y"
      data['tot_enroll_unit'].should == "1"
      data['cal_residency_flag'].should == "N"
      data[:roles][:student].should == true
      data[:roles][:faculty].should == false
      data[:roles][:staff].should == true
    end
  end

  it "should find Stu TestB's registration status" do
    data = CampusData.get_reg_status(300846)
    if CampusData.test_data?
      data['ldap_uid'].should == "300846"
      # we will only have predictable reg_status_cd values in our fake Oracle db.
      data['reg_status_cd'].should == "C"
    end
  end

  it "should return nil from get_reg_status if an existing user has no reg status" do
    data = CampusData.get_reg_status("2040")
    data.should be_nil
  end

  it "should return nil from get_reg_status if the user does not exist" do
    data = CampusData.get_reg_status("0")
    data.should be_nil
  end

  it "should find some students in Biology 1a" do
    students = CampusData.get_enrolled_students("7309", "2013", "D")
    students.should_not be_nil
    if CampusData.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      students.empty?.should be_false
    end
    students.each do |student_row|
      student_row["enroll_status"].blank?.should be_false
      student_row["student_id"].blank?.should be_false
    end
  end

  it "should find a course" do
    course = CampusData.get_course_from_section("7366", "2013", "B")
    course.should_not be_nil
    if CampusData.test_data?
      # we will only have predictable data in our fake Oracle db.
      course["course_title"].should == "General Biology Lecture"
      course["dept_name"].should == "BIOLOGY"
      course["catalog_id"].should == "1A"
    end
  end

  it "should find courses from sections" do
    courses = CampusData.get_courses_from_sections("2013", "D", ["7309", "7366", "7372", "16171"])
    pp courses
    courses.should_not be_nil
    if CampusData.test_data?
      courses.length.should == 2
      courses.index{|c|
        c['dept_name'] == "BIOLOGY" &&
        c['catalog_id'] == "1A" &&
        c['course_title'] == "General Biology Lecture"
      }.should_not be_nil
    end
  end

  it "should find sections from course" do
    sections = CampusData.get_sections_from_course('BIOLOGY', '1A', 2013, 'D')
    sections.empty?.should be_false
    if CampusData.test_data?
      # Should not include canceled section
      sections.length.should == 3
      # Should include at least one lecture section
      sections.index{|s| s['instruction_format'] == 'LEC'}.should_not be_nil
    end
  end

  it "should find where a person is enrolled, with grades where available" do
    sections = CampusData.get_enrolled_sections('300939')
    sections.should_not be_nil
    if CampusData.test_data?
      sections.length.should == 6
      sections[0]["grade"].should be_nil
      sections[4]["grade"].should == "B "
      sections[5]["grade"].should == "C+"
    end
  end

  it "should find where a person is teaching" do
    sections = CampusData.get_instructing_sections('192517')
    sections.should_not be_nil
    sections.length.should == 5 if CampusData.test_data?
  end

  it "should check whether the db is alive" do
    alive = CampusData.database_alive?
    alive.should be_true
  end

  it "should report DB outage" do
    CampusData.connection.stub(:select_one).and_raise(
        ActiveRecord::StatementInvalid,
        "Java::JavaSql::SQLRecoverableException: IO Error: The Network Adapter could not establish the connection: select 1 from DUAL"
    )
    is_ok = CampusData.database_alive?
    is_ok.should be_false
  end

  it "should handle a person with no affiliations" do
    # Temp Agency Staff has no affiliations
    data = CampusData.get_person_attributes(321765)
    data[:roles].each do |role_name, role_value|
      role_value.should be_false
    end
  end

  it "should return class schedule data" do
    data = CampusData.get_section_schedules("2013", "D", "16171")
    data.should_not be_nil
    if CampusData.test_data?
      data[0]["building_name"].should == "WHEELER"
      data[1]["building_name"].should == "DWINELLE"
    end
  end

  it "should return instructor data given a course control number" do
    data = CampusData.get_section_instructors("2013", "D", "7309")
    data.should_not be_nil
    if CampusData.test_data?
      data.length.should == 2
      data[0]["person_name"].should == "Yu-Hung Lin"
      data[0]["instructor_func"].should == "1"
      data[1]["person_name"].should == "Chris Tweney"
      data[1]["instructor_func"].should == "4"
    end
  end

  it "should be able to get a whole lot of user records" do
    known_uids = ['192517', '238382', '2040', '3060', '211159', '322279']
    lotsa_uids = Array.new(1000 - known_uids.length) {|i| i + 1 }
    lotsa_uids.concat(known_uids)
    user_data = CampusData.get_basic_people_attributes(lotsa_uids)
    user_data.each do |row|
      known_uids.delete(row['ldap_uid'])
    end
    known_uids.empty?.should be_true
  end

  it "should be able to look up Tammi's student info" do
    info = CampusData.get_student_info "300939"
    info.should_not be_nil
    if CampusData.test_data?
      info["first_reg_term_cd"].should == "D"
      info["first_reg_term_yr"].should == "2013"
    end
  end

  it "should use affiliations to decide whether the user is a student" do
    CampusData.is_student?(
        {
            'student_id' => 1,
            'affiliations' => 'AFFILIATE-TYPE-GENERAL,EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED'
        }
    ).should be_false
    CampusData.is_student?(
        {
            'student_id' => 2,
            'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-STAFF'
        }
    ).should be_true
    CampusData.is_student?(
        {
            'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-STAFF'
        }
    ).should be_false
    CampusData.is_student?(
        {
            'student_id' => 3,
            'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-TYPE-NOT REGISTERED'
        }
    ).should be_true
  end

end
