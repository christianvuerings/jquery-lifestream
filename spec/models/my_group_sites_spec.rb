require "spec_helper"

describe "MyGroupSites" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_sakai_proxy = SakaiProxy.new({fake: true})
  end

  it "should return a valid feed for a user granted access" do
    SakaiProxy.stub(:access_granted?).and_return(true)
    my_groups = MyGroupSites.get_feed(@user_id)
    my_groups.is_a?(Array).should == true
    my_groups.each do |group_hash|
      group_hash.keys do |key|
        group_hash[key].should_not be_nil
      end
    end
  end

  it "should return a empty array for non-authenticated users" do
    SakaiProxy.stub(:access_granted?).and_return(false)
    empty_groups = MyGroupSites.get_feed(@user_id)
    empty_groups.is_a?(Array).should == true
    empty_groups.size.should == 0
  end

  it "should reject malformed Sakai2 entries" do
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
    my_groups = MyGroupSites.get_feed(@user_id)
    my_groups.size.should == 1
  end

end
