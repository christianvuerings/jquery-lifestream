require 'spec_helper'

describe 'GoogleEventsList (Recent Items)' do

  before do
    @random_id = rand(999999).to_s
  end

  after { WebMock.reset! }

  it "should get real events list using the Tammi account", :testext => true do
    proxy = GoogleApps::EventsRecentItems.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    response_enum = proxy.recent_items
    response_enum.first.data["kind"].should == "calendar#events"
    response_enum.first.status.should == 200
  end
end
