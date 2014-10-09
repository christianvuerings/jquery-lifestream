require "spec_helper"

describe MyBadgesController do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_drive_list = GoogleApps::DriveList.new(:fake => true)
    @fake_events_list = GoogleApps::EventsRecentItems.new(:fake => true)
    allow(Settings.features).to receive(:reauthentication).and_return(false)
  end

  it "should be an empty badges feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty badges feed on authenticated user" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DriveList.stub(:new).and_return(@fake_drive_list)
    GoogleApps::EventsRecentItems.stub(:new).and_return(@fake_events_list)
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)

    if json_response["alert"].present?
      json_response["alert"].is_a?(Hash).should be_truthy
      json_response["alert"].keys.count.should >= 3
    end

    json_response["badges"].present?.should be_truthy
    json_response["badges"].is_a?(Hash).should be_truthy
    json_response["badges"].keys.count.should == 3

    existing_badges = %w(bcal bdrive bmail)
    existing_badges.each do |badge|
      json_response["badges"][badge]["count"].should_not be_nil
    end

    json_response["studentInfo"].present?.should be_truthy
    json_response["studentInfo"].is_a?(Hash).should be_truthy
    json_response["studentInfo"].keys.count.should == 4
  end

  context 'viewing-as' do
    let(:user_id) { rand(99999).to_s }
    let(:original_user_id) { rand(99999).to_s }
    before do
      session[:user_id] = user_id
      expect(Settings.google_proxy).to receive(:fake).at_least(:once).and_return(true)
      expect(Settings.app_alerts_proxy).to receive(:fake).at_least(:once).and_return(true)
      expect(Settings.bearfacts_proxy).to receive(:fake).at_least(:once).and_return(true)
    end
    it 'should not give a real user a cached censored feed' do
      session[:original_user_id] = original_user_id
      get :get_feed
      feed = JSON.parse(response.body)
      ['bcal', 'bdrive', 'bmail'].each do |service|
        expect(feed['badges'][service]['count']).to eq 0
      end
      session[:original_user_id] = nil
      get :get_feed
      feed = JSON.parse(response.body)
      ['bcal', 'bdrive', 'bmail'].each do |service|
        expect(feed['badges'][service]['count']).to be > 0
      end
    end
    it 'should not return Google data from a cached real-user feed' do
      get :get_feed
      feed = JSON.parse(response.body)
      expect(feed['alert']['title']).to be_present
      expect(feed['studentInfo']['regBlock']).to be_present
      ['bcal', 'bdrive', 'bmail'].each do |service|
        expect(feed['badges'][service]['count']).to be > 0
      end
      session[:original_user_id] = original_user_id
      get :get_feed
      feed = JSON.parse(response.body)
      expect(feed['alert']['title']).to be_present
      expect(feed['studentInfo']['regBlock']).to be_present
      ['bcal', 'bdrive', 'bmail'].each do |service|
        expect(feed['badges'][service]['count']).to eq 0
      end
    end
  end

end
