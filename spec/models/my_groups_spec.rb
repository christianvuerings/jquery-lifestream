require "spec_helper"

describe "MyGroups" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas = {
        groups: [{
                      id: '1023614',
                      emitter: 'bCourses'
                  }]
    }
    @fake_sakai = {
        groups: [{
                      id: '095d5b02-afde-4186-a668-0b84734b1d5c',
                      emitter: 'bSpace'
                  }]
    }
    @fake_cal_link_proxy = CalLinkMembershipsProxy.new({fake: true})
  end

  it "should return a empty array for non-authenticated users" do
    empty_groups = MyGroups.new(nil).get_feed
    empty_groups[:groups].is_a?(Array).should == true
    empty_groups[:groups].size.should == 0
  end

  it "should include Canvas groups" do
    CalLinkProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasUserSites.any_instance.stub(:get_feed).and_return(@fake_canvas)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].is_a?(Array).should == true
    my_groups[:groups].size.should be > 0
    my_groups[:groups].each do |group_hash|
      group_hash.keys do |key|
        group_hash[key].should_not be_nil
        group = group_hash[key]
        group[:emitter].should == "bCourses"
      end
    end
  end

  context "Fake Callink groups tests" do
    before(:each) do
      @orig_setting = Settings.cal_link_proxy.fake
      Settings.cal_link_proxy.fake = true
      CanvasProxy.stub(:access_granted?).and_return(false)
      SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
      CalLinkProxy.stub(:access_granted?).and_return(true)
      CalLinkMembershipsProxy.stub(:new).and_return(@fake_cal_link_proxy)
    end

    after(:each) do
      Settings.cal_link_proxy.fake = @orig_setting
    end

    let(:my_groups) { MyGroups.new(@user_id).get_feed }

    subject { my_groups[:groups] }

    it "should include non-empty CalLink groups" do
      subject.is_a?(Array).should be_true
      subject.size.should be > 0
      subject.each do |group_hash|
        group_hash.keys do |key|
          group_hash[key].should_not be_nil
          group = group_hash[key]
          group[:id].blank?.should be_false
          group[:name].blank?.should be_false
          group[:site_url].blank?.should be_false
          group[:emitter].should == "CalLink"
        end
      end
    end

    it "should filter out blacklisted CalLink groups" do
      subject.is_a?(Array).should == true
      bad_groups = %w(91370 59672 45984 46063 91891 93520 67825)
      (subject.select {|group| bad_groups.include?(group[:id])}).should be_empty
      (subject.select {|group| group[:emitter] == "CalLink"}).should be_present
    end

  end





  it "should sort groups alphabetically" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    CalLinkProxy.stub(:access_granted?).and_return(false)
    sakai_project_site_feed = {groups: [
        {name: "Zsite", id: "zsite-id", site_url: "http://sakai/zsite-id"},
        {name: "csite", id: "csite-id", site_url: "http://sakai/csite-id"}
    ]}
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return(sakai_project_site_feed)
    canvas_groups_feed = {groups: [
        {name: 'Agroup', id: 'agroup-id', site_url: "http://canvas/agroup-id"}
    ]}
    CanvasUserSites.any_instance.stub(:get_feed).and_return(canvas_groups_feed)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups][0][:name].should == "Agroup"
    my_groups[:groups][1][:name].should == "csite"
    my_groups[:groups][2][:name].should == "Zsite"
  end

  it "should return bSpace sites when Canvas and CalLink services are unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    CalLinkProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).
        and_return({
                       groups: [
                           {
                               name: "Sakai Reunion Planning",
                               id: "xxx-yyy",
                               site_url: "http://www.example.com/site/xxx-yyy",
                               emitter: SakaiProxy::APP_ID
                           }
                       ]
                   })
    CanvasProxy.any_instance.stub(:request).and_return(nil)
    CalLinkMembershipsProxy.stub(:new).and_return(@fake_cal_link_proxy)
    CalLinkMembershipsProxy.any_instance.stub(:get_memberships).and_return({status_code: 503})
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].size.should be > 0
    my_groups[:groups].each do |group|
      group[:emitter].should == "bSpace"
    end
  end

end
