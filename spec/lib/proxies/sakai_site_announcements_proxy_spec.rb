require "spec_helper"

describe SakaiSiteAnnouncementsProxy do

  before do
    # Site IDs in test data
    @site_with_ten_current = '29fc31ae-ff14-419f-a132-5576cae2474e'
    @site_with_one_current = '45042d5d-9b88-43cf-a83a-464e1f0444fc'
    @unpublished_site = 'cc56df9a-3ae1-4362-a4a0-6c5133ec8750'
    @site_group_with_one = '282e0a88-d923-46fe-85f9-1db0e4048e19'
  end

  it "should return something even when there is no announcement tool in the site" do
    client = SakaiSiteAnnouncementsProxy.new({site_id: 'no-such-site'})
    announcements = client.get_announcements
    announcements.should_not be_nil
    announcements.size.should == 0
  end

  it "should possibly even return live data" do
    client = SakaiSiteAnnouncementsProxy.new({site_id: @site_with_ten_current})
    client.message_max_length.should be > 0
    announcements = client.get_announcements
    announcements.each do |announcement|
      announcement['message_id'].blank?.should be_false
      announcement['message_date'].should_not be_nil
      announcement['source_url'].blank?.should be_false
      announcement['summary'].length.should be <= client.message_max_length
    end
  end

  it "should find seeded attachments", :if => SakaiData.test_data? do
    client = SakaiSiteAnnouncementsProxy.new({site_id: @site_with_ten_current})
    announcements = client.get_announcements
    attachments = []
    announcements.each do |announcement|
      attachments << announcement['attachments'] if announcement['attachments']
    end
    attachments.size.should == 2
  end

  it "should return only site-wide announcements by default", :if => SakaiData.test_data? do
    client = SakaiSiteAnnouncementsProxy.new({site_id: @site_with_ten_current})
    all_announcements = client.get_all_announcements
    all_announcements.size.should == 10
    sitewide_announcements = client.get_announcements
    sitewide_announcements.size.should == 8
    filtered_announcements = client.get_announcements([@site_group_with_one])
    filtered_announcements.size.should == 9
  end

  it "should not receive draft, lapsed, or unreleased announcements", :if => SakaiData.test_data? do
    client = SakaiSiteAnnouncementsProxy.new({site_id: @site_with_one_current})
    announcements = client.get_announcements
    announcements.size.should == 1
  end

end
