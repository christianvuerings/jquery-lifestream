require "spec_helper"

describe CanvasController do

  let(:role) { 'TeacherEnrollment' }
  let(:course_user_hash) do
    {
      'id' => 4321321, 'name' => "Michael Steven OWEN", 'sis_user_id' => "UID:105431", 'sis_login_id' => "105431", 'login_id' => "105431",
      'enrollments' => [
        {'id' => 20241907, 'course_id' => 767330, 'course_section_id' => 1312468, 'type' => role, 'role' => role}
      ]
    }
  end

  before do
    session[:user_id] = "12345"
    session[:canvas_user_id] = "4321321"
    session[:canvas_course_id] = "767330"
    CanvasCourseUserProxy.any_instance.stub(:course_user).and_return(course_user_hash)
  end

  context "when serving course user profile information" do

    context "when no user session present" do
      before { session[:user_id] = nil }
      it "returns 401 error" do
        get :course_user_profile
        expect(response.status).to eq(401)
        expect(response.body).to eq " "
      end
    end

    context "when no canvas user id present" do
      before { session[:canvas_user_id] = nil }
      it "returns 401 error" do
        get :course_user_profile
        expect(response.status).to eq(401)
        expect(response.body).to eq " "
      end
    end

    context "when no canvas course id present" do
      before { session[:canvas_course_id] = nil }
      it "returns 401 error" do
        get :course_user_profile
        expect(response.status).to eq(401)
        expect(response.body).to eq " "
      end
    end

    context "when session with canvas user and course id present" do
      context "when canvas user not a member of the course" do
        before { CanvasCourseUserProxy.any_instance.stub(:course_user).and_return(nil) }
        it "returns 401 error" do
          get :course_user_profile
          expect(response.status).to eq(401)
          expect(response.body).to eq " "
        end
      end

      it "returns course user details" do
        get :course_user_profile
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['course_user_profile']).to be_an_instance_of Hash
        course_user = response_json['course_user_profile']
        expect(course_user).to be_an_instance_of Hash
        expect(course_user['id']).to eq 4321321
        expect(course_user['name']).to eq "Michael Steven OWEN"
        expect(course_user['sis_user_id']).to eq "UID:105431"
        expect(course_user['sis_login_id']).to eq "105431"
        expect(course_user['login_id']).to eq "105431"
        expect(course_user['enrollments']).to be_an_instance_of Array
        expect(course_user['enrollments'].count).to eq 1
        expect(course_user['enrollments'][0]['course_id']).to eq 767330
        expect(course_user['enrollments'][0]['course_section_id']).to eq 1312468
        expect(course_user['enrollments'][0]['id']).to eq 20241907
        expect(course_user['enrollments'][0]['type']).to eq "TeacherEnrollment"
        expect(course_user['enrollments'][0]['role']).to eq "TeacherEnrollment"
      end
    end

    context "when exception is raised" do
      it "returns 500 error with json error message" do
        CanvasCourseUserProxy.any_instance.stub(:course_user).and_raise(RuntimeError, 'This is the error message')
        get :course_user_profile
        expect(response.status).to eq(500)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq 'This is the error message'
      end
    end

  end

end
