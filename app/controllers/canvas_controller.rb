class CanvasController < ApplicationController
  include ClassLogger

  include CanvasAuthorizationHelpers
  before_filter :authenticate_cas_user!, :only => [:course_user_profile]
  before_filter :authenticate_canvas_user!, :only => [:course_user_profile]
  before_filter :authenticate_canvas_course_user!, :only => [:course_user_profile]
  rescue_from ClientError, with: :handle_client_error
  rescue_from StandardError, with: :handle_api_exception

  # Used to obtain LTI user in context of course embedded apps
  # GET /api/academics/canvas/course_user_profile
  def course_user_profile
    canvas_user_id = Integer(session[:canvas_user_id], 10)
    canvas_course_id = Integer(session[:canvas_course_id], 10)
    render json: { course_user_profile: @canvas_course_user }.to_json
  end

end
