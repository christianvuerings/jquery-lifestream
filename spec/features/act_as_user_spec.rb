require "spec_helper"

feature "act_as_user" do
  before do
    @fake_events_list = GoogleEventsListProxy.new(fake: true)
    UserAuth.new_or_update_superuser! "238382"
    UserAuth.new_or_update_test_user! "2040"
    UserAuth.new_or_update_test_user! "1234"
    UserAuth.new_or_update_test_user! "9876"
  end

  scenario "switch to another user and back while using a super-user" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    UserData.stub(:where, :uid => '2040').and_return("tricking the first login check")
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user "2040"
    }
    UserData.unstub(:where)
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "2040"
    suppress_rails_logging {
     stop_act_as_user
    }
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "238382"
  end

  scenario "switch to another user without clicking stop acting as" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    login_with_cas "238382"
    act_as_user "2040"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "2040"

    act_as_user "1234"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "1234"

    act_as_user "9876"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "9876"

    # make sure you can act-as someone with no user_auth record
    act_as_user "54321"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "54321"

    stop_act_as_user
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "238382"
  end

  scenario "provide faulty param while switching users" do
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user "gobbly-gook"
    }
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "238382"
  end

  scenario "making sure act_as doesn't expose google data for non-fake users", :testext => true do
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    UserAuth.new_or_update_superuser! "2040"
    UserData.stub(:where, :uid => '2040').and_return("tricking the first login check")
    %w(238382 2040 11002820).each do |user|
      login_with_cas user
      visit "/api/my/up_next"
      response = JSON.parse(page.body)
      response["items"].empty?.should be_false
      Rails.cache.exist?("user/#{user}/MyUpNext").should be_true
    end
    login_with_cas "238382"
    act_as_user "2040"
    UserData.unstub(:where)
    visit "/api/my/up_next"
    response = JSON.parse(page.body)
    response["items"].empty?.should be_true
    UserData.stub(:where, :uid => '11002820').and_return("tricking the first login check")
    act_as_user "11002820"
    UserAuth.new_or_update_test_user! "11002820"
    UserData.unstub(:where)
    visit "/api/my/up_next"
    response = JSON.parse(page.body)
    response["items"].empty?.should be_false
  end
end
