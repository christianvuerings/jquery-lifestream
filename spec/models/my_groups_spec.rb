require "spec_helper"

describe "MyGroups" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas = {
        groups: [{
                      id: '1023614',
                      emitter: 'Canvas'
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
        group[:emitter].should == "Canvas"
      end
    end
  end

  it "should include CalLink groups" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CalLinkProxy.stub(:access_granted?).and_return(true)
    CalLinkMembershipsProxy.stub(:new).and_return(@fake_cal_link_proxy)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].is_a?(Array).should == true
    my_groups[:groups].size.should == 5
    my_groups[:groups].each do |group_hash|
      group_hash.keys do |key|
        group_hash[key].should_not be_nil
        group = group_hash[key]
        group[:id].blank?.should be_false
        group[:title].blank?.should be_false
        group[:site_url].blank?.should be_false
        group[:emitter].should == "CalLink"
        group[:color_class].should == "callink-group"
      end
    end
  end

  it "should sort groups alphabetically" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    CalLinkProxy.stub(:access_granted?).and_return(false)
    sakai_project_site_feed = {groups: [
        {title: "Zsite", id: "zsite-id", site_url: "http://sakai/zsite-id"},
        {title: "csite", id: "csite-id", site_url: "http://sakai/csite-id"}
    ]}
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return(sakai_project_site_feed)
    canvas_groups_feed = {groups: [
        {title: 'Agroup', id: 'agroup-id', site_url: "http://canvas/agroup-id"}
    ]}
    CanvasUserSites.any_instance.stub(:get_feed).and_return(canvas_groups_feed)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups][0][:title].should == "Agroup"
    my_groups[:groups][1][:title].should == "csite"
    my_groups[:groups][2][:title].should == "Zsite"
  end

  it "should return bSpace sites when Canvas and CalLink services are unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    CalLinkProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).
        and_return({
                       groups: [
                           {
                               title: "Sakai Reunion Planning",
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
