require "spec_helper"

describe MyResearchGroupsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty research feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

#  it "should check for valid fields on the my groups feed" do
    #needs to be updated afterwards
#    session[:user_id] = @user_id
#    get :get_feed
#    json_response = JSON.parse(response.body)
#    json_response["research"].is_a?(Array).should == true
#    json_response["research"].each do |group_entry|
#      group_entry["title"].blank?.should_not == true
#      group_entry["shortName"].blank?.should_not == true
#    end

#  it "should return 500 error" do
#    session[:user_id] = 12345678911
#    get :get_feed
#    response.status.should == 500
#  end
end
