require "spec_helper"

describe "CampusCourseSectionsProxy" do

  it "should return pre-populated test sections", :if => SakaiData.test_data? do
    client = CampusCourseSectionsProxy.new({term_yr: '2013', term_cd: 'C', ccn: '16171'})
    data = client.get_section_data
    data.empty?.should be_false

    data[:instructors].length.should == 1
    data[:instructors][0][:name].should == "Yu-Hung Lin"
    data[:instructors][0][:uid].should == "192517"
    data[:schedules].length.should == 2
    data[:schedules][0][:schedule].should == "TuTh 2:00P-3:30P"
    data[:schedules][0][:building_name].should == "WHEELER"
    data[:schedules][1][:schedule].should == "W 4:00P-5:30P"
    data[:schedules][1][:building_name].should == "DWINELLE"
  end

  it "should correctly translate schedule codes" do
    client = CampusCourseSectionsProxy.new({user_id: '300939'})
    client.translate_meeting(
      {
        "meeting_days" => "S"
      }).should == "Su"
    client.translate_meeting(
      {
        "meeting_days" => "SMTWTFS",
        "meeting_start_time" => "0900",
        "meeting_start_time_ampm_flag" => "A",
        "meeting_end_time" => "1100",
        "meeting_end_time_ampm_flag" => "P"
      }).should == "SuMTuWThFSa 9:00A-11:00P"
    client.translate_meeting(
      {
        "meeting_days" => "  T T  "
      }).should == "TuTh"
    client.translate_meeting(nil).should == ""
  end

end
