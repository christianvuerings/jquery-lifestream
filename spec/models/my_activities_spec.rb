require "spec_helper"

describe "MyActivities" do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_sakai_user_sites = SakaiUserSitesProxy.new(fake: true)
    @fake_bearfacts_proxy = BearfactsRegblocksProxy.new(fake: true)
    @fake_canvas_proxy = CanvasUserActivityStreamProxy.new(fake: true)
    @documented_types = ['alert', 'announcement', 'assignment',
                         'discussion', 'grade_posting', 'message', 'webconference']
  end

  it "should get properly formatted Sakai announcements when Canvas is not available", :if => SakaiData.test_data? do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_user_sites)
    BearfactsRegblocksProxy.stub(:new).and_return(@fake_bearfacts_proxy)
    my_activities = MyActivities.new(@user_id).get_feed
    my_activities[:activities].empty?.should be_false
    my_activities[:activities].each do |act|
      act[:emitter].should == 'bSpace'
      act[:type].should == 'announcement'
      act[:source].blank?.should be_false
    end
  end

  it "should successfuly handle well translated responses from notifications" do
    user = UserApi.new "300846"
    user.record_first_login
    processor = RegStatusEventProcessor.new
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(
      {
        "ldap_uid" => "300846",
        "reg_status_cd" => "C"
      })
    processor.process(event, timestamp).should == true

    CanvasProxy.stub(:access_granted?).and_return(false)
    saved_notification = Notification.where(:uid => "300846").first
    activities = MyActivities.new("300846").get_feed[:activities]
    notification_activities = activities.select {|notification| notification[:source] == 'Bearfacts:RegStatus'}
    notification_activities.empty?.should_not be_true
  end

  it "should successfuly handle badly translated responses from notifications" do
    user = UserApi.new "300846"
    user.record_first_login
    processor = RegStatusEventProcessor.new
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(
      {
        "ldap_uid" => "300846",
        "reg_status_cd" => "C"
      })
    processor.process(event, timestamp).should == true

    CanvasProxy.stub(:access_granted?).and_return(false)
    saved_notification = Notification.where(:uid => "300846").first
    RegStatusTranslator.any_instance.stub(:translate).and_return false
    activities = MyActivities.new("300846").get_feed[:activities]
    notification_activities = activities.select {|notification| notification[:source] == 'Bearfacts:RegStatus'}
    notification_activities.empty?.should be_true
  end

  it "should get properly formatted Canvas activities when bSpace is not available" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasUserActivityStreamProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return({})
    my_activities = MyActivities.new(@user_id).get_feed
    my_activities[:activities].empty?.should be_false
    my_activities[:activities].each do |act|
      act[:emitter].should == 'bCourses'
      @documented_types.include?(act[:type]).should be_true
    end
  end


  context "MyRegBlocks" do
    it "should get properly formatted registration blocks from fake Bearfacts" do
      CanvasProxy.stub(:access_granted?).and_return(false)
      SakaiProxy.stub(:access_granted?).and_return(false)
      oski_bearfacts_proxy = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
      BearfactsRegblocksProxy.stub(:new).and_return(oski_bearfacts_proxy)
      oski_activities = MyActivities.new("61889").get_feed
      oski_activities[:activities].empty?.should be_false
      oski_activities[:activities].each do |act|
        act[:emitter].should == "BearFacts"
        act[:source].should_not == "Bearfacts"
        @documented_types.include?(act[:type]).should be_true
      end
    end

    it "include in feed for recently cleared, very old blocks" do
      CanvasProxy.stub(:access_granted?).and_return(false)
      SakaiProxy.stub(:access_granted?).and_return(true)
      SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_user_sites)
      oski_bearfacts_proxy = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
      BearfactsRegblocksProxy.stub(:new).and_return(oski_bearfacts_proxy)
      oski_blocks = MyRegBlocks.new({user_id: "61889", fake: true})
      mangled_inactive = oski_blocks.get_feed[:inactive_blocks].map do |block|
        {
          cleared_date: oski_blocks.format_date(Time.now.to_datetime),
          blocked_date: oski_blocks.format_date(Time.at(0).to_datetime)
        }.reverse_merge(block)
      end
      mangled_oski_blocks = oski_blocks.get_feed.merge({ inactive_blocks: mangled_inactive })
      MyRegBlocks.any_instance.stub(:get_feed).and_return(mangled_oski_blocks)

      oski_activities = MyActivities.new("61889").get_feed
      oski_activities[:activities].empty?.should be_false
      oski_activities[:activities].select do |act|
        act[:emitter]== "BearFacts" && act[:type] == "message" && act[:title].include?("Block Cleared")
      end

    end

    context "4xx response from bearfacts proxy" do
      before(:each) { MyRegBlocks.any_instance.stub(:get_feed).and_return({ available: false }) }

      it "should not malform the activities passed into append_reg_blocks" do
        my_activities = MyActivities.new(@user_id)
        activities = "foo"
        my_activities.send(:append_regblocks, activities)
        activities.should eq("foo")
      end
    end
  end


end
