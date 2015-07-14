class CanvasWebcastRecordingsController < ApplicationController
  include SpecificToCourseSite

  before_filter :api_authenticate
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /api/academics/canvas/media/:canvas_course_id
  # A Canvas course ID of "embedded" means to retrieve from session properties.
  def get_media
    raise Errors::BadRequestError, "Bad course site ID #{canvas_course_id}" if canvas_course_id.blank?
    course = Canvas::Course.new(canvas_course_id: canvas_course_id)
    authorize course, :can_view_course?
    render :json => CanvasLti::WebcastRecordings.new(session['user_id'], policy(course), canvas_course_id).get_feed
  end

end
