class CanvasRostersController < RostersController
  include ClassLogger
  include SpecificToCourseSite

  before_filter :api_authenticate
  before_filter :authorize_viewing_rosters
  before_action :disable_xframe_options, :only => [:get_csv]
  skip_before_action :set_x_frame_options_header
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_viewing_rosters
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in embedded rosters request: session user = #{session[:user_id]}" unless canvas_course_id
    canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => canvas_course_id)
    authorize canvas_course, :can_view_course_roster_photos?
  end

  # GET /api/academics/rosters/canvas/:canvas_course_id
  def get_feed
    feed = Canvas::CanvasRosters.new(session[:user_id], course_id: canvas_course_id).get_feed_filtered
    render :json => feed.to_json
  end

  # GET /api/academics/rosters/canvas/csv/:canvas_course_id.csv
  def get_csv
    rosters_csv = Canvas::CanvasRosters.new(session[:user_id], course_id: canvas_course_id).get_csv
    respond_to do |format|
      format.csv { render csv: rosters_csv.to_s, filename: "course_#{canvas_course_id}_rosters" }
    end
  end

  # GET /canvas/:canvas_course_id/photo/:person_id
  def photo
    course_id = params[:canvas_course_id]
    course_user_id = Integer(params[:person_id], 10)
    @photo = Canvas::CanvasRosters.new(session[:user_id], course_id: course_id).photo_data_or_file(course_user_id)
    serve_photo
  end

end
