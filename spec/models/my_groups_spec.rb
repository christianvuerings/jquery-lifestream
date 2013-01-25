require "spec_helper"

describe "MyGroups" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_sakai_proxy = SakaiCategorizedProxy.new({fake: true})
    @fake_canvas_proxy = CanvasGroupsProxy.new({fake: true})
  end

  it "should return a valid feed for a user granted access" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].is_a?(Array).should == true
    my_groups[:groups].each do |group_hash|
      group_hash.keys do |key|
        group_hash[key].should_not be_nil
      end
    end
  end

  it "should return a empty array for non-authenticated users" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(false)
    empty_groups = MyGroups.new(@user_id).get_feed
    empty_groups[:groups].is_a?(Array).should == true
    empty_groups[:groups].size.should == 0
  end

  it "should reject malformed Sakai2 entries" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    site_template = @fake_sakai_proxy.get_categorized_sites(@user_id)
    site_template[:body]["categories"].each do |category|
      if category["category"] == "Projects" && category["sites"].size >= 1
        #One valid entry
        test_sites = category["sites"].slice(0,1)
        test_sites[0]["title"] = ""
        test_sites << {"title"=>"My Bad Id",
                       "id"=>nil, "url"=>"https://www.google.com",
                       "description"=>"<p>My Bad Id Site</p>"}
        test_sites << {"title"=>"My Bad Url",
                       "id"=>"1", "url"=>"",
                       "description"=>"<p>My Bad Url Site</p>"}
      end
    end
    SakaiProxy.any_instance.stub(:get_categorized_sites).and_return(site_template)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups.size.should == 1
  end

  it "should include Canvas groups" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(false)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].is_a?(Array).should == true
    my_groups[:groups].size.should be > 0
    my_groups[:groups].each do |group_hash|
      group_hash.keys do |key|
        group_hash[key].should_not be_nil
        group = group_hash[key]
        group[:id].blank?.should be_false
        group[:title].blank?.should be_false
        group[:site_url].blank?.should be_false
        group[:emitter].should == "Canvas"
        group[:color_class].should == "canvas-group"
      end
    end
  end

  it "should sort groups alphabetically" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:access_granted?).and_return(true)
    sakai_project_site_feed = {status_code: 200, body: {"categories" => [
        "category" => "Projects",
        "sites" => [
            {"title" => "Zsite", "id" => "zsite-id", "url" => "http://sakai/zsite-id"},
            {"title" => "csite", "id" => "csite-id", "url" => "http://sakai/csite-id"}
        ]
    ]}}
    SakaiCategorizedProxy.any_instance.stub(:get_categorized_sites).and_return(sakai_project_site_feed)
    canvas_groups_feed = '[{"name": "Agroup", "id": "agroup-id"}]'
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    @fake_canvas_proxy.stub_chain(:groups, :body).and_return(canvas_groups_feed)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups][0][:title].should == "Agroup"
    my_groups[:groups][1][:title].should == "csite"
    my_groups[:groups][2][:title].should == "Zsite"
  end

  it "should return bSpace sites when Canvas service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiCategorizedProxy.stub(:new).and_return(@fake_sakai_proxy)
    CanvasProxy.any_instance.stub(:request).and_return(nil)
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].size.should be > 0
    my_groups[:groups].each do |group|
      group[:emitter].should == "bSpace"
    end
  end

  it "should return Canvas groups when bSpace service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.any_instance.stub(:do_get).and_return({status_code: 503})
    my_groups = MyGroups.new(@user_id).get_feed
    my_groups[:groups].size.should be > 0
    my_groups[:groups].each do |group|
      group[:emitter].should == "Canvas"
    end
  end

end
