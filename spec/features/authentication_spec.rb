require "spec_helper"

feature "authentication" do
  scenario "Working authentication, login and logout" do
    # Logging in and out quickly also triggers a rapid cache warming and expiration issue.
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    login_with_cas "238382"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_truthy
    response["uid"].should == "238382"
    logout_of_cas
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_falsey
  end

  scenario "Failing authentication" do
    original_logger = OmniAuth.config.logger

    begin
      OmniAuth.config.logger = Logger.new "/dev/null"
      break_cas
      login_with_cas "238382"
      page.status_code.should == 401
      restore_cas "238382"
    ensure
      OmniAuth.config.logger = original_logger
    end
  end

  scenario "broken authentication" do
    login_with_cas "oski.bear@stanford.edu"
    current_path.should eq("/uid_error")
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["isLoggedIn"].should be_falsey
  end
end
