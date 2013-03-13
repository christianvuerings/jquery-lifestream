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
        site['id'].blank?.should_not be_true
        site['url'].blank?.should_not be_true
      end
    end
  end

  it "should not see class sites for non-current terms", :if => SakaiData.test_data? do
    all_sites = SakaiData.get_users_sites(SakaiData.get_sakai_user_id(@uid))
    excluded_term_idx = all_sites.index{|s| s['term'] && !@client.current_terms.include?(s['term'])}
    excluded_term_idx.should_not be_nil
    excluded_term = all_sites[excluded_term_idx]['term']
    category_map = @client.get_categorized_sites
    category_map[excluded_term].should be_nil
  end

  it "should not see unpublished sites", :if => SakaiData.test_data? do
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      sites.each do |site|
        site['id'].should_not == @unpublished_site_id
      end
    end
  end

  it "should not see hidden sites" do
    hidden_sites = SakaiData.get_hidden_site_ids(SakaiData.get_sakai_user_id(@uid))
    category_map = @client.get_categorized_sites
    category_map.each_value do |sites|
      sites.each do |site|
        hidden_sites.include?(site['id']).should_not be_true
      end
    end
  end

end
