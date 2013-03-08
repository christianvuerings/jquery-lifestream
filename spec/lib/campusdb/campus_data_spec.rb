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
      data[:roles][:staff].should == false
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

  it "should find some students in Spanish 1" do
    students = CampusData.get_enrolled_students("86103", "2012", "D")
    students.should_not be_nil
    if CampusData.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      students[6]["ldap_uid"].should == "300846"
    end
  end

  it "should find a course" do
    course = CampusData.get_course("7366", "2012", "D")
    course.should_not be_nil
    if CampusData.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      course["course_title"].should == "General Biology Lecture"
      course["dept_name"].should == "BIOLOGY"
      course["catalog_id"].should == "1A"
    end
  end

  it "should check whether the db is alive" do
    alive = CampusData.check_alive
    alive.should_not be_nil
  end

end
