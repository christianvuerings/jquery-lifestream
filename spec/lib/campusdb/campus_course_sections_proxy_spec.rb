require "spec_helper"

describe "CampusCourseSectionsProxy" do

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

  describe "get_section_data" do

    it "should return pre-populated test sections", :if => SakaiData.test_data? do
      client = CampusCourseSectionsProxy.new({term_yr: '2013', term_cd: 'D', ccn: '16171'})
      data = client.get_section_data
      data.empty?.should be_false

      data[:instructors].length.should == 1
      data[:instructors][0][:name].present?.should be_true
      data[:instructors][0][:uid].should == "238382"
      data[:schedules].length.should == 2
      data[:schedules][0][:schedule].should == "TuTh 2:00P-3:30P"
      data[:schedules][0][:building_name].should == "WHEELER"
      data[:schedules][1][:schedule].should == "W 4:00P-5:30P"
      data[:schedules][1][:building_name].should == "DWINELLE"
    end

    it "should filter out the empty schedules" do
      stubbed_schedules = [
        {"building_name"=>"OFF CAMPUS", "room_number"=>nil, "meeting_days"=>"    T", "meeting_start_time"=>"0330", "meeting_start_time_ampm_flag"=>"P", "meeting_end_time"=>"0630", "meeting_end_time_ampm_flag"=>"P"},
        {"building_name"=>nil, "room_number"=>nil, "meeting_days"=>nil, "meeting_start_time"=>nil, "meeting_start_time_ampm_flag"=>nil, "meeting_end_time"=>nil, "meeting_end_time_ampm_flag"=>nil},
      ]
      client = CampusCourseSectionsProxy.new({term_yr: '2013', term_cd: 'D', ccn: '16171'})
      # CampusData.get_section_schedules(@term_yr, @term_cd, @ccn)
      CampusData.should_receive(:get_section_schedules).and_return(stubbed_schedules)
      #allow(CampusData).to receive(:get_section_schedules).and_return(stubbed_schedules)
      result = client.get_section_data

      result.should be_an_instance_of Hash
      result.should have_key(:schedules)
      result[:schedules].length.should == 1

    end

  end

end
