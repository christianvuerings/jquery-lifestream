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
    course_feed = @client.get_categorized_sites[:classes]
    bad_idx = course_feed.index{|s| s[:id] == excluded_site_id}
    bad_idx.should be_nil
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

  it "should see any course offerings associated with a course site" do
    course_feed = @client.get_categorized_sites[:classes]
    if SakaiData.test_data?
      course_feed.each do |site|
        site[:courses].should_not be_nil
        site[:courses].each do |course_info|
          course_info[:dept].should_not be_nil
          course_info[:catid].should_not be_nil
          course_info[:term_cd].should_not be_nil
          course_info[:term_yr].should_not be_nil
        end
      end
    end
  end

end
