class CanvasRostersController < RostersController
  include ClassLogger

  before_filter :api_authenticate
  before_filter :authorize_viewing_rosters
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_viewing_rosters
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in embedded rosters request: session user = #{session[:user_id]}" if session[:canvas_course_id].blank?
    canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => session[:canvas_course_id].to_i)
    authorize canvas_course, :is_canvas_course_teacher_or_assistant?
  end

  # GET /api/academics/rosters/canvas/embedded
  def get_feed
    feed = Canvas::CanvasRosters.new(session[:user_id], course_id: session[:canvas_course_id].to_i).get_feed
    render :json => feed.to_json
  end

  # GET /canvas/:canvas_course_id/photo/:person_id
  def photo
    course_id = params[:canvas_course_id]
    course_user_id = Integer(params[:person_id], 10)
    @photo = Canvas::CanvasRosters.new(session[:user_id], course_id: course_id).photo_data_or_file(course_user_id)
    serve_photo
  end

end
