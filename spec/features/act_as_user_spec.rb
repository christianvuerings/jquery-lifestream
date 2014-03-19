require "spec_helper"

feature "act_as_user" do
  before do
    @fake_events_list = Google::EventsList.new(fake: true)
    User::Auth.new_or_update_superuser! "238382"
    User::Auth.new_or_update_test_user! "2040"
    User::Auth.new_or_update_test_user! "1234"
    User::Auth.new_or_update_test_user! "9876"
  end

  scenario "switch to another user and back while using a super-user" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    User::Data.stub(:where, :uid => '2040').and_return("tricking the first login check")
    login_with_cas "238382"
    suppress_rails_logging {
      act_as_user "2040"
    }
    User::Data.unstub(:where)
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



  scenario "make sure admin users don't modify database records of the users they view" do
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)

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
    page.status_code.should == 204
    viewed_user = User::Data.where(:uid=>viewed_user_uid).first
    viewed_user.should_not be_nil
    viewed_user.uid.should == viewed_user_uid
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
    Google::Proxy.stub(:access_granted?).and_return(true)
    Google::EventsList.stub(:new).and_return(@fake_events_list)
    User::Auth.new_or_update_superuser! "2040"
    User::Data.stub(:where, :uid => '2040').and_return("tricking the first login check")
    %w(238382 2040 11002820).each do |user|
      login_with_cas user
      visit "/api/my/up_next"
      response = JSON.parse(page.body)
      response["items"].empty?.should be_false
      Rails.cache.exist?("user/#{user}/UpNext::MyUpNext").should be_true
    end
    login_with_cas "238382"
    act_as_user "2040"
    User::Data.unstub(:where)
    visit "/api/my/up_next"
    response = JSON.parse(page.body)
    response["items"].empty?.should be_true
    User::Data.stub(:where, :uid => '11002820').and_return("tricking the first login check")
    act_as_user "11002820"
    User::Auth.new_or_update_test_user! "11002820"
    User::Data.unstub(:where)
    visit "/api/my/up_next"
    response = JSON.parse(page.body)
    response["items"].empty?.should be_false
  end
end
