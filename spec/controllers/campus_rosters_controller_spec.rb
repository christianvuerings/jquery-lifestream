require "spec_helper"
require "support/canvas_shared_examples"

describe CampusRostersController do

  let(:campus_course_id) { "mec_eng-132-2014-b" }
  let(:user_id) { rand(99999) }

  context "when serving course rosters feed" do

    before { session[:user_id] = user_id }

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Rosters::Campus).to receive(:get_feed).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :get_feed, campus_course_id: campus_course_id }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_feed, campus_course_id: campus_course_id }
    end

    it "should return error for campus rosters if user is not authorized" do
      Rosters::Campus.any_instance.stub(:get_feed).and_return(nil)
      get :get_feed, campus_course_id: campus_course_id
      assert_response(401)
      student_id = rand(99999)
      get :photo, campus_course_id: campus_course_id, person_id: student_id
      assert_response(401)
    end

  end

end
