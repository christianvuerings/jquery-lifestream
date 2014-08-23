require "spec_helper"
require "support/canvas_shared_examples"

describe CanvasRostersController do
  let(:user_id)           { Settings.canvas_proxy.test_user_id }
  let(:canvas_course_id)  { "767330" }
  let(:student_id)        { rand(99999) }
  let(:roster_feed) do
    {
      "canvas_course" => {"id" => 27},
      "sections" => [
        {
          "id" => 34,
          "name" => "COMPSCI 47C SLF 001",
          "sis_id" => "SEC:2014-D-25749"
        }
      ],
      "students" => [
        {
          "student_id" => "24899123",
          "first_name" => "Sam",
          "last_name" => "Samwich",
          "enroll_status" => "E",
          "id" => 4886773,
          "sections" => [{"id" => 1394824}],
          "profile_url" => "https://ucberkeley.beta.instructure.com/courses/1224681/users/4886773",
          "login_id" => "1038892",
          "photo" => "/canvas/1224681/photo/4886773"
        },
        {
          "student_id" => "23973124",
          "first_name" => "Kate",
          "last_name" => "Kathimyer",
          "enroll_status" => "E",
          "id" => 4911017,
          "sections" => [{"id" => 1394824}],
          "profile_url" => "https://ucberkeley.beta.instructure.com/courses/1224681/users/4911017",
          "login_id" => "1006997",
          "photo" => "/canvas/1224681/photo/4911017"
        },
      ]
    }
  end
  let(:photo_file) { {:data => '\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01'} }

  before do
    # emulate user authenticated via LTI Launch from a Canvas Course
    session[:user_id] = user_id
    session[:canvas_course_id] = canvas_course_id
    allow_any_instance_of(Canvas::CoursePolicy).to receive(:is_canvas_course_teacher_or_assistant?).and_return(true)
    allow_any_instance_of(Canvas::CanvasRosters).to receive(:get_feed).and_return(roster_feed)
  end

  context "when serving course rosters feed" do

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::CanvasRosters).to receive(:get_feed).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :get_feed, canvas_course_id: 'embedded' }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_feed, canvas_course_id: 'embedded' }
    end

    context "when canvas course requested via non-embedded session" do
      before { session[:canvas_course_id] = nil }
      it "should response with roster feed" do
        get :get_feed, canvas_course_id: canvas_course_id
        assert_response :success
        json_response = JSON.parse(response.body)
        expect(json_response["canvas_course"]).to be_an_instance_of Hash
        expect(json_response["sections"]).to be_an_instance_of Array
        expect(json_response["students"]).to be_an_instance_of Array
        expect(json_response["canvas_course"]["id"]).to eq 27
        expect(json_response["students"][0]["student_id"]).to eq "24899123"
        expect(json_response["students"][1]["student_id"]).to eq "23973124"
      end
    end

    context "when user is authorized" do
      it "should respond with roster feed" do
        get :get_feed, canvas_course_id: 'embedded'
        assert_response :success
        json_response = JSON.parse(response.body)
        expect(json_response["canvas_course"]).to be_an_instance_of Hash
        expect(json_response["sections"]).to be_an_instance_of Array
        expect(json_response["students"]).to be_an_instance_of Array
        expect(json_response["canvas_course"]["id"]).to eq 27
        expect(json_response["students"][0]["student_id"]).to eq "24899123"
        expect(json_response["students"][1]["student_id"]).to eq "23973124"
      end
    end

    context "when user is not authorized" do
      before { allow_any_instance_of(Canvas::CoursePolicy).to receive(:is_canvas_course_teacher_or_assistant?).and_return(false) }
      it "should respond with empty http 403" do
        get :get_feed, canvas_course_id: 'embedded'
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end

    context "when canvas course id not present" do
      before { session[:canvas_course_id] = nil }
      it "should respond with empty http 403" do
        get :get_feed, canvas_course_id: 'embedded'
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end

  end

  context "when serving course enrollee photo" do
    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::CanvasRosters).to receive(:get_feed).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :photo, canvas_course_id: canvas_course_id, person_id: student_id }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :photo, canvas_course_id: canvas_course_id, person_id: student_id }
    end

    it "should return error if user is not authorized" do
      allow_any_instance_of(Canvas::CoursePolicy).to receive(:is_canvas_course_teacher_or_assistant?).and_return(false)
      get :photo, canvas_course_id: canvas_course_id, person_id: student_id
      assert_response(403)
    end

    context "if photo path returned for enrollee" do
      before { allow_any_instance_of(Canvas::CanvasRosters).to receive(:photo_data_or_file).and_return(photo_file) }
      it "should return photo" do
        get :photo, canvas_course_id: canvas_course_id, person_id: student_id
        assert_response :success
      end
    end

  end

end
