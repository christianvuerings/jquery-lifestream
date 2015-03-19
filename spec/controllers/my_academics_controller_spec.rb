require "spec_helper"
require "support/shared_examples"

describe MyAcademicsController do

  context "when serving academics feed" do
    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_feed }
    end

    it "should get a non-empty feed for an authenticated (but fake) user" do
      session['user_id'] = "0"
      get :get_feed
      json_response = JSON.parse(response.body)
      json_response["regblocks"]["noStudentId"].should be_truthy
    end
  end

end
