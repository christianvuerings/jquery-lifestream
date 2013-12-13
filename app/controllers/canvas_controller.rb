class CanvasController < ApplicationController
  include ClassLogger
  include CanvasControllerHelpers

  before_filter :authenticate_user!, :only => [:course_user_profile]
  before_filter :authenticate_course_user!, :only => [:course_user_profile]

  # Used to obtain LTI user in context of course embedded apps
  # GET /api/academics/canvas/course_user_profile
  def course_user_profile
    canvas_user_id = Integer(session[:canvas_user_id], 10)
    canvas_course_id = Integer(session[:canvas_course_id], 10)
    render json: { course_user_profile: @canvas_course_user }.to_json
  rescue StandardError => error
    respond_with_json_error(500, error.message)
  end

end
