require "spec_helper"

describe RoutesListController do

  before do
    @user_id = rand(999999).to_s
  end

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  it "should not list any routes for not logged in users" do
    get :smoke_test_routes
    assert_response 401
  end

  it "should not list any routes for non-superusers" do
    UserAuth.stub(:where).and_return([UserAuth.new(uid: @user_id, is_superuser: false, active: true)])
    session[:user_id] = @user_id
    get :smoke_test_routes
    assert_response 401
  end

  it "should list some /api/ routes for superusers" do
    UserAuth.stub(:where).and_return([UserAuth.new(uid: @user_id, is_superuser: true, active: true)])
    session[:user_id] = @user_id
    get :smoke_test_routes
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response['routes'].present?.should be_true
    bad_entries = json_response['routes'].select {|route| !route.start_with? '/api/' }
    bad_entries.empty?.should be_true
  end

end
