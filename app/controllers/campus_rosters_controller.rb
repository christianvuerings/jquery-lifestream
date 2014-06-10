class CampusRostersController < RostersController
  include ClassLogger

  before_filter :api_authenticate
  before_filter :authorize_viewing_rosters
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_viewing_rosters
    # raise Pundit::NotAuthorizedError, "Canvas Course ID not present in embedded rosters request: session user = #{session[:user_id]}" if session[:canvas_course_id].blank?
    # canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => session[:canvas_course_id].to_i)
    # authorize canvas_course, :is_canvas_course_teacher_or_assistant?
  end

  # GET /api/academics/rosters/campus/:campus_course_id
  def get_feed
    if (model = valid_model(params[:campus_course_id], "Campus"))
      if (feed = model.get_feed)
        render :json => feed.to_json
      else
        render :nothing => true, :status => 401
      end
    else
      render :nothing => true, :status => 401
    end
  end

end
