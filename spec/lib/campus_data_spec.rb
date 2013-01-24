require "spec_helper"

describe CampusData do
  it "should find Oliver" do
    data = CampusData.get_person_attributes(2040)
    data['first_name'].should == "Oliver"
  end

  it "should find Stu TestB's registration status" do
    data = CampusData.get_reg_status(300846)
    data['ldap_uid'].should == "300846"
    if Settings.campusdb.adapter == "h2"
      # we will only have predictable reg_status_cd values in our fake Oracle db.
      data['reg_status_cd'].should == "C"
    end
  end
end
