require "spec_helper"

describe CanvasRostersController do

  it "should return error if not authorized" do
    user_id = rand(99999)
    canvas_course_id = rand(999999).to_s
    session[:user_id] = user_id
    Canvas::CanvasRosters.any_instance.stub(:get_feed).and_return(nil)
    get :get_feed, canvas_course_id: canvas_course_id
    assert_response(401)
    student_id = rand(99999)
    get :photo, canvas_course_id: canvas_course_id, person_id: student_id
    assert_response(401)
  end

  it "should retrieve the Canvas course ID from the session when embedded" do
    user_id = rand(99999)
    canvas_course_id = rand(999999)
    session[:user_id] = user_id
    session[:canvas_course_id] = canvas_course_id.to_s
    stub_model = double
    Canvas::CanvasRosters.should_receive(:new).with(user_id, {course_id: canvas_course_id}).and_return(stub_model)
    stub_model.should_receive(:get_feed).and_return(
        {
            sections: [],
            students: []
        }
    )
    get :get_feed, canvas_course_id: 'embedded'
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response["sections"].should_not be_nil
    json_response["students"].should_not be_nil
  end

end
