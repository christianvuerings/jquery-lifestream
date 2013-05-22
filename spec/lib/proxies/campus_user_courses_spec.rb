require "spec_helper"

describe CampusUserCoursesProxy do

  it "should be accessible if non-null user" do
    CampusUserCoursesProxy.access_granted?(nil).should be_false
    CampusUserCoursesProxy.access_granted?('211159').should be_true
    client = CampusUserCoursesProxy.new({user_id: '211159'})
    client.get_campus_courses.should_not be_nil
  end

  it "should return pre-populated test enrollments", :if => SakaiData.test_data? do
    client = CampusUserCoursesProxy.new({user_id: '300939'})
    courses = client.get_campus_courses
    courses.empty?.should be_false
    courses.each do |course|
      course[:id].blank?.should be_false
      course[:site_url].blank?.should be_false
      course[:emitter].should == 'Campus'
      course[:name].blank?.should be_false
      course[:color_class].should == 'campus-class'
      ['Student', 'Instructor'].include?(course[:role]).should be_true
      course[:instruction_format].blank?.should be_false
      course[:section_num].blank?.should be_false
      if course[:ccn] == "16171"
        course[:building_name].should == "WHEELER"
        course[:instructor].should == "Yu-Hung Lin"
        course[:schedule].should == "TuTh 2:00P-3:30P"
      end
    end
  end

  it "should correctly translate schedule codes" do
    client = CampusUserCoursesProxy.new({user_id: '300939'})
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
