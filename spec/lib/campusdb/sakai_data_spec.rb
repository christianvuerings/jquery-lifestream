require "spec_helper"

describe SakaiData do

  before do
    # Assume that the integrated Sakai server has an account for this user.
    @live_data_uid = '211159'
  end

  def live_sakai_user_id
    @sakai_user_id ||= SakaiData.get_sakai_user_id(@live_data_uid)
  end

  it "should find a known user" do
    live_sakai_user_id.blank?.should be_false
  end

  it "should not find an unknown user" do
    sakai_user_id = SakaiData.get_sakai_user_id('nosuchuser')
    sakai_user_id.blank?.should be_true
  end

  it "should read hidden site preferences if any" do
    hidden_sites = SakaiData.get_hidden_site_ids(live_sakai_user_id)
    hidden_sites.should_not be_nil
  end

  it "should find site memberships" do
    sites = SakaiData.get_users_sites(live_sakai_user_id)
    sites.should_not be_nil
    sites.size.should be > 0 if SakaiData.test_data?
    sites.each do |site|
      site['site_id'].blank?.should be_false
    end
  end

  it "should find announcements" do
    end_range = Time.zone.now.to_datetime
    start_range = end_range.advance(months: -1)
    site_ids = SakaiData.get_users_sites(live_sakai_user_id)
    site_ids.each do |site_id|
      if SakaiData.get_announcement_tool_id(site_id)
        announcements = SakaiData.get_announcements(site_id, start_range, end_range)
        announcements.should_not be_nil
        announcements.each do |announcement|
          announcement['message_id'].blank?.should be_false
        end
      end
    end
  end

end
