require "spec_helper"

describe CampusRostersController do

  it "should return error for campus rosters if user is not authorized" do
    user_id = rand(99999)
    session[:user_id] = user_id
    campus_course_id = "mec_eng-132-2014-b"

    Rosters::Campus.any_instance.stub(:get_feed).and_return(nil)
    get :get_feed, campus_course_id: campus_course_id
    assert_response(401)
    student_id = rand(99999)
    get :photo, campus_course_id: campus_course_id, person_id: student_id
    assert_response(401)
  end

end
