class CampusRostersController < RostersController
  include ClassLogger

  before_filter :api_authenticate
  before_filter :authorize_viewing_rosters
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_viewing_rosters
    raise Errors::BadRequestError, "campus_course_id required" unless params[:campus_course_id]
    course = Berkeley::Course.new(:course_id => params[:campus_course_id])
    authorize course, :can_view_roster_photos?
  end

  # GET /api/academics/rosters/campus/:campus_course_id
  def get_feed
    feed = Rosters::Campus.new(session[:user_id], course_id: params[:campus_course_id]).get_feed_filtered
    render :json => feed.to_json
  end

  # GET /campus/:campus_course_id/photo/:person_id
  def photo
    course_id = params[:campus_course_id]
    course_user_id = Integer(params[:person_id], 10)
    @photo = Rosters::Campus.new(session[:user_id], course_id: course_id).photo_data_or_file(course_user_id)
    serve_photo
  end

end
