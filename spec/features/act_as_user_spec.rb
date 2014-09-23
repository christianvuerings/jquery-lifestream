require "spec_helper"

feature "act_as_user" do
  before do
    @target_uid = "978966"
    @fake_events_list = GoogleApps::EventsList.new(fake: true)
    User::Auth.new_or_update_superuser! "238382"
    User::Auth.new_or_update_superuser! "2040"
    Settings.features.stub(:reauthentication).and_return(false)
  end

  scenario "switch to another user and back while using a super-user" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    User::Data.stub(:where, :uid => '2040').and_return("tricking the first login check")
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user "2040"
    }
    User::Data.unstub(:where)
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "2040"
    suppress_rails_logging {
     stop_act_as_user
    }
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "238382"
  end

  scenario "make sure admin users can act as a user who has never signed in before" do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    super_user_uid = "238382"
    act_as_uid = @target_uid
    # act_as user has never logged in
    User::Data.where(:uid=>act_as_uid).first.should be_nil
    # log into CAS with the super user
    login_with_cas super_user_uid
    # stub out the environment, faking as production
    Settings.application.stub(:layer).and_return("production")
    # make the act_as request
    page.driver.post '/act_as', {:uid=>act_as_uid}
    # failing attempts will redirect to the root_path, giving a 302 statusCode
    # successful attempts don't redirect and return nothing but a 204 status code
    page.status_code.should == 204
  end


  scenario "make sure admin users don't modify database records of the users they view" do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)

    # you don't want the admin user to record a first log for a "viewed as" user that does not exist in the database
    impossible_uid = '78903478484358033984502345858034583043548034580'
    User::Data.where(:uid=>impossible_uid).should be_empty
    login_with_cas "238382" # super user
    suppress_rails_logging {
      act_as_user impossible_uid
    }
    page.driver.post '/api/my/record_first_login'
    page.status_code.should == 204
    User::Data.where(:uid=>impossible_uid).should be_empty

    # you don't want the admin user to record a visit that's wasn't really made by the "viewed as" user
    visit '/api/my/status'
    page.status_code.should == 200
    User::Visit.where(:uid=>'4').should be_empty

    # you don't want the admin user to delete an existing "viewed as" user's data row
    viewed_user_uid = "2040"
    fake_user = User::Data.create(:uid=>viewed_user_uid)
    User::Data.where(:uid=>viewed_user_uid).should_not be_empty
    suppress_rails_logging {
      act_as_user "2040"
    }
    page.driver.post '/api/my/opt_out'
    page.status_code.should == 403
    viewed_user = User::Data.where(:uid=>viewed_user_uid).first
    viewed_user.should_not be_nil
    viewed_user.uid.should == viewed_user_uid
  end

  scenario "check the footer message for a user that has logged in" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)

    login_with_cas "238382"
    act_as_user '2040'

    page.driver.post '/api/my/record_first_login'
    page.status_code.should == 204

    visit "/api/my/status"
    response = JSON.parse(page.body)
    response['uid'].should == '2040'
    response['firstLoginAt'].should be_nil

    # visit "/settings"
    # html = page.body
    # page.body.should =~ /You're currently viewing as.+first logged in on/m
    # Note: it's possible to check for hardcoded text with regular expressions on the
    # rendered html, but there's no apparent way to detect the text rendered by angular
  end

  scenario "check the footer message for a user that has never logged in" do
    target_uid = "211159"
    login_with_cas "238382"
    act_as_user target_uid

    page.driver.post '/api/my/record_first_login'
    page.status_code.should == 204

    visit "/api/my/status"
    response = JSON.parse(page.body)
    response['uid'].should == target_uid
    response['firstLoginAt'].should be_nil

    # visit "/settings"
    # html = page.body
    # page.body.should =~ /You're currently viewing as.+who has never logged in to CalCentral/m
    # Note: it's possible to check for hardcoded text with regular expressions on the
    # rendered html, but there's no apparent way to detect the text rendered by angular
  end

  scenario "check the act-as footer text" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    login_with_cas "238382"
    act_as_user "2040"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "2040"

    act_as_user "978966"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "978966"

    act_as_user "211159"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "211159"

    # make sure you can act-as someone with no user_auth record
    act_as_user "904715"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "904715"

    stop_act_as_user
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "238382"
  end

  scenario "provide faulty param while switching users" do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user "gobbly-gook"
    }
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "238382"
  end

  scenario "making sure act_as doesn't expose google data", :testext => true do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::EventsList.stub(:new).and_return(@fake_events_list)
    User::Data.stub(:where, :uid => '2040').and_return("tricking the first login check")
    %w(238382 2040 11002820).each do |user|
      login_with_cas user
      visit "/api/my/up_next"
      response = JSON.parse(page.body)
      response["items"].empty?.should be_false
      Rails.cache.exist?(UpNext::MyUpNext.cache_key(user)).should be_true
    end
    login_with_cas "238382"
    act_as_user "2040"
    User::Data.unstub(:where)
    visit "/api/my/up_next"
    response = JSON.parse(page.body)
    response["items"].empty?.should be_true
  end

  scenario "make sure you cannot act as an invalid user" do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    invalid_uid = "89923458987947"
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user invalid_uid
    }
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_true
    response["uid"].should == "238382"
  end
end
