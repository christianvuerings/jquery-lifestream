require 'spec_helper'
require 'headless'
require 'selenium-webdriver'

feature 'MyBadges urls:' do
  def selenium_check_url_exists(url, truthy_match = nil)
    truthy_match ||= url
    visit url
    within("div.email-div") { fill_in "Email", with: Settings.google_proxy.test_user_email }
    within("div.passwd-div") { fill_in "Passwd", with: Settings.google_proxy.test_user_password }
    click_on "Sign in"
    visit url
    sleep 5 #waiting for redirect
    current_url.include?(truthy_match).should be_true
    malformed_link = url[0..-2] + "ohnoes"
    visit malformed_link
    sleep 5 #waiting for redirect
    current_url.include?(malformed_link).should be_false
  end

  before(:all) do
    @headless = Headless.new(display: 98)
    @headless.start
  end

  after(:all) do
    @headless.destroy if @headless
  end

  before(:each) do
    Capybara.current_driver = :selenium
    @user_id = rand(999999).to_s
    @real_mail_list = GoogleMailListProxy.new(
      :fake => false,
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    @real_calendar_events = GoogleEventsListProxy.new(
      :fake => false,
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  scenario 'see if munged urls from google_mail badges resolve', :testext => true do
    #This requires a live mailbox with a non-empty INBOX.
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return(@real_mail_list)

    results = MyBadges::GoogleMail.new(@user_id).fetch_counts
    results[:items].size.should_not == 0
    selenium_check_url_exists results[:items].first[:link]
  end

  scenario 'see if munged urls from google_calendar badges resolve', :testext => true do
    #This requires an existing event to be exist from the time listed below.
    event_listed_after = "2013-05-09T12:42:02-07:00"
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleEventsListProxy.stub(:new).and_return(@real_calendar_events)
    results = MyBadges::GoogleCalendar.new(@user_id).fetch_counts(
      {
        timeMin: event_listed_after,
        updatedMin: nil
      })
    results[:items].size.should_not == 0
    first_link = results[:items].first[:link]
    eid = Rack::Utils.parse_query(URI.parse(first_link).query)['eid']
    selenium_check_url_exists(first_link, eid)
  end
end