require "spec_helper"

feature "assume_user" do
  before do
    #The switching back and forth before users makes the cache warmer go crazy
    @default_logger = Celluloid.logger
    Celluloid.logger = nil
  end

  after do
    Celluloid.logger = @default_logger
  end

  scenario "switch to another user and back while using a super-user" do
    # disabling the cache_warmer while we're switching back and forth between users
    # The switching back triggers a cache invalidation, while the warming thread is still running.
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    UserData.stub(:where, :uid => '2040').and_return("tricking the first login check")
    login_with_cas "192517"
    UserAuth.stub(:is_superuser?, '192517').and_return(true)
    assume_user "2040"
    UserData.unstub(:where)
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "2040"
    unassume_user
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "192517"
  end

  scenario "provide faulty param while switching users" do
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    login_with_cas "192517"
    UserAuth.stub(:is_superuser?, '192517').and_return(true)
    assume_user "gobbly-gook"
    visit "/api/my/status"
    response = JSON.parse(page.body)
    response["is_logged_in"].should be_true
    response["uid"].should == "192517"
  end
end