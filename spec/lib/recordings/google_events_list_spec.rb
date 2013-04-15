require 'spec_helper'

describe 'GoogleEventsList' do

  before do
    @random_id = rand(999999).to_s
  end

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  it "should get real events list using the Tammi account", :testext => true do
    proxy = GoogleEventsListProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    # Recording response for :maxResults => 10 to force paged responses testing.
    response_enum = proxy.events_list({:maxResults => 10, :page_limiter => 2})
    response_enum.first.data["kind"].should == "calendar#events"
    # Normal recording.
    response_enum = proxy.events_list
    response_enum.first.data["kind"].should == "calendar#events"
  end
end