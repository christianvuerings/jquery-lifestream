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
    students = CampusData.get_enrolled_students("7309", "2013", "B")
    students.should_not be_nil
    if CampusData.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      students.empty?.should be_false
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
    courses = CampusData.get_courses_from_sections("2013", "B", ["7309", "7366", "7372", "16171"])
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
    sections = CampusData.get_sections_from_course('BIOLOGY', '1A', 2013, 'B')
    sections.empty?.should be_false
    if CampusData.test_data?
      # Should not include canceled section
      sections.length.should == 3
      # Should include at least one lecture section
      sections.index{|s| s['instruction_format'] == 'LEC'}.should_not be_nil
    end
  end

  it "should find where a person is enrolled" do
    sections = CampusData.get_enrolled_sections('300939', 2013, 'B')
    sections.should_not be_nil
    sections.length.should == 2 if CampusData.test_data?
  end

  it "should find where a person is teaching" do
    sections = CampusData.get_instructing_sections('192517', 2013, 'B')
    sections.should_not be_nil
    sections.length.should == 1 if CampusData.test_data?
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

end
