require "spec_helper"

describe SakaiUserSitesProxy do

  before do
    @uid = '300939'
    @client = SakaiUserSitesProxy.new({user_id: @uid})
    @unpublished_site_id = 'cc56df9a-3ae1-4362-a4a0-6c5133ec8750'
  end

  it "should get categorized sites from bSpace" do
    category_map = @client.get_categorized_sites
    category_map.should_not be_nil
    category_map.each do |category, sites|
      category.empty?.should_not be true
      sites.each do |site|
        site[:id].blank?.should_not be_true
        site[:site_url].blank?.should_not be_true
      end
    end
  end

  it "should not see class sites for non-current terms", :if => SakaiData.test_data? do
    all_sites = SakaiData.get_users_sites(SakaiData.get_sakai_user_id(@uid))
    excluded_term_idx = all_sites.index{|s| s['term'] && !@client.current_terms.include?(s['term'])}
    excluded_term_idx.should_not be_nil
    excluded_site_id = all_sites[excluded_term_idx]['site_id']
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      bad_idx = sites.index{|s| s[:id] == excluded_site_id}
      bad_idx.should be_nil
    end
  end

  it "should not see unpublished sites", :if => SakaiData.test_data? do
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      sites.each do |site|
        site[:id].should_not == @unpublished_site_id
      end
    end
  end

  it "should not see hidden sites" do
    hidden_sites = SakaiData.get_hidden_site_ids(SakaiData.get_sakai_user_id(@uid))
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      sites.each do |site|
        hidden_sites.include?(site[:id]).should_not be_true
      end
    end
  end

  it "should see site group memberships" do
    nbr_memberships = 0
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      sites.each do |site|
        if site[:groups]
          nbr_memberships += site[:groups].length
        end
        nbr_memberships.should == 1 if SakaiData.test_data?
      end
    end
  end

  it "should see any course offerings associated with a course site if enrolled" do
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return([
        {
            id: "LAW-201S-2013-D",
            term_yr: "2013",
            term_cd: "D",
            dept: "LAW",
            catid: "201S",
            course_code: "LAW 201S",
            sections: [{ccn: "55810"}, {ccn: "55835"}],
            role: "Student"
        }
    ])
    SakaiData.stub(:get_users_sites).and_return ([
        {
            "site_id"=>"rackety-chile",
            "type"=>"course",
            "title"=>"Law 201S",
            "term"=>"Fall 2013",
            "short_desc"=>"A legal course site",
            "provider_id"=>"2013-D-14645+2013-D-55835"
        }
    ])
    sites_feed = @client.get_categorized_sites
    sites_feed[:classes].length.should == 1
    site = sites_feed[:classes][0]
    site[:short_description].should == "A legal course site"
    site[:name].should == "Law 201S"
    site[:courses].length.should == 1
    site[:courses][0][:id].should == "LAW-201S-2013-D"
  end

  it "should put a course site in classes if enrolled as an instructor" do
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return([
         {
             id: "LAW-201S-2013-D",
             term_yr: "2013",
             term_cd: "D",
             dept: "LAW",
             catid: "201S",
             course_code: "LAW 201S",
             sections: [{ccn: "55810"}, {ccn: "55835"}],
             role: "Instructor"
         },
         {
             id: "DWIN-117-2013-D",
             term_yr: "2013",
             term_cd: "D",
             dept: "DWIN",
             catid: "117",
             course_code: "DWIN 117",
             sections: [{ccn: "95959"}],
             role: "Student"
         }
    ])
    SakaiData.stub(:get_users_sites).and_return ([
        {
            "site_id"=>"rackety-chile",
            "type"=>"course",
            "title"=>"A legal course site",
            "term"=>"Fall 2013",
            "provider_id"=>"2013-D-14645+2013-D-55835"
        },
        {
            "site_id"=>"bricka-brack",
            "type"=>"course",
            "title"=>"An off-the-books course site",
            "term"=>"Fall 2013",
            "provider_id"=>"2013-D-34985"
        },
        {
          "site_id"=>"never-ending-project",
          "type"=>"project",
          "title"=>"trivial project",
          "term"=>"Fall 2013",
          "provider_id"=>"2013-D-1"
        }
    ])
    sites_feed = @client.get_categorized_sites
    sites_feed[:groups].length.should == 1
    sites_feed[:classes].length.should == 2
    non_official_class = 0
    official_class = 0
    sites_feed[:classes].each do |site|
      site[:site_type].should == 'course'
      site[:name].blank?.should be_false
      if site[:courses].present?
        official_class += 1
      else
        non_official_class += 1
      end

    end
 end

end
