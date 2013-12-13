module CanvasControllerHelpers

  def authenticate_user!
    if session[:user_id].blank?
      respond_to_bad_api_request("No session user") and return
    end
  end

  def authenticate_course_user!
    if session[:canvas_user_id].blank?
      respond_to_bad_api_request("No canvas user id") and return
    end
    if session[:canvas_course_id].blank?
      respond_to_bad_api_request("No canvas course id") and return
    end
    @canvas_user_id = Integer(session[:canvas_user_id], 10)
    @canvas_course_id = Integer(session[:canvas_course_id], 10)
    canvas_course_user_proxy = CanvasCourseUserProxy.new(:user_id => @canvas_user_id, :course_id => @canvas_course_id)
    unless @canvas_course_user = canvas_course_user_proxy.course_user
      respond_to_bad_api_request("Canvas user #{@canvas_user_id} is not a member of Course ID #{@canvas_course_id}") and return
    end
  rescue StandardError => error
    respond_with_json_error(500, error.message) and return
  end

  def respond_to_bad_api_request(warning_message = nil)
    logger.warn "Bad request made to #{controller_name}\##{action_name}: #{warning_message}" if warning_message.present?
    render nothing: true, status: 401
  end

  def respond_with_json_error(http_status_code, error_msg)
    render json: { :error => error_msg }.to_json, status: http_status_code
  end

end

