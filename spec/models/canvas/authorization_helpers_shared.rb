# The methods provided by the Canvas::AuthorizationHelpers module are applied to Canvas controllers
# in unique configurations to provide desired behavior. Because of this, the shared examples below
# are intended to be applied to the spec for controllers in a way that verifies the same configuration
# of unique behaviors.
#
# Example:
#   context "when serving requests for the users profile" do
#     it_should_behave_like "a user authenticated controller" do
#       let(:make_request) { get :user_profile }
#     end
#   end
#
# In this example, the controller action that serves the users profile ensures that the user is CAS authenticated
# before proceeding with the primary logic of the request (returning user profile json).
#
require "set"

shared_examples "a user authenticated controller" do
  context "when no user session present" do
    before { session[:user_id] = nil }
    it "returns 401 error" do
      make_request
      expect(response.status).to eq(401)
      expect(response.body).to eq " "
    end
  end
end

shared_examples "a canvas user authenticated controller" do
  let(:canvas_user_profile) do
    {
      "id"=>43232321,
      "name"=>"Ludwig Van BEETHOVEN",
      "short_name"=>"Ludwig BEETHOVEN",
      "sortable_name"=>"BEETHOVEN, Ludwig",
      "sis_user_id"=>"UID:105431",
      "sis_login_id"=>"105431",
      "login_id"=>"105431",
      "avatar_url"=>"https://secure.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50",
      "title"=>nil,
      "bio"=>nil,
      "primary_email"=>"luwdig.van.beethoven@berkeley.edu",
      "time_zone"=>"America/Los_Angeles"
    }
  end

  let(:canvas_user_profile_failure) do
    {
      "status"=>"not_found",
      "message"=>"The specified resource does not exist.",
      "error_report_id"=>73417549
    }
  end

  let(:successful_canvas_user_profile_response) do
    response = double
    response.stub(:status).and_return(200)
    response.stub(:body).and_return(canvas_user_profile.to_json)
    response
  end

  let(:failed_canvas_user_profile_response) do
    response = double
    response.stub(:status).and_return(404)
    response.stub(:body).and_return(canvas_user_profile_failure.to_json)
    response
  end

  context "when no canvas user id present" do
    before { session[:canvas_user_id] = nil }

    context "when canvas user id exists" do
      before do
        Canvas::UserProfile.any_instance.stub(:user_profile).and_return(successful_canvas_user_profile_response)
      end

      it "sets canvas user id in session" do
        make_request
        expect(session[:user_id]).to eq("12345")
        expect(session[:canvas_user_id]).to eq("43232321")
      end
    end

    context "when canvas user does not exist" do
      before { Canvas::UserProfile.any_instance.stub(:user_profile).and_return(failed_canvas_user_profile_response) }
      it "returns 401 error" do
        make_request
        expect(session[:user_id]).to eq("12345")
        expect(session[:canvas_user_id]).to_not eq("43232321")
        expect(session[:canvas_user_id]).to eq(nil)
        expect(response.status).to eq(401)
        expect(response.body).to eq " "
      end
    end
  end
end

shared_examples "a canvas course user authenticated controller" do
  context "when no canvas course id present" do
    before { session[:canvas_course_id] = nil }

    context "when canvas course id provided as request parameter" do
      it "the canvas course id is set in the session" do
        make_request_with_course_id
        expect(session[:canvas_course_id]).to eq "4123456"
      end
    end

    context "when canvas course id not provided as request parameter" do
      it "the canvas course id is not set in the session" do
        expect(session[:canvas_course_id]).to_not eq "4123456"
        expect(session[:canvas_course_id]).to be_nil
      end

      it "returns 401 error" do
        make_request
        expect(response.status).to eq(401)
        expect(response.body).to eq " "
      end
    end
  end
end

shared_examples "a canvas course admin authorized controller" do
  context "when canvas user is not an admin in canvas course" do
    before { Canvas::CourseUser.stub(:is_course_admin?).and_return(false) }
    it "returns 403 error" do
      make_request
      expect(response.status).to eq(403)
      expect(response.body).to eq " "
    end
  end
end

shared_examples "an api endpoint" do
  context "when standarderror exception raised" do
    it "returns 500 error" do
      make_request
      expect(response.status).to eq(500)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to be_an_instance_of String
      expect(json_response['error']).to eq "Something went wrong"
    end
  end
end
