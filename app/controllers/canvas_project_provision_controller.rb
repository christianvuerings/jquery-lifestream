class CanvasProjectProvisionController < ApplicationController
  include ClassLogger

  before_filter :api_authenticate
  before_filter :authorize_creating_project_site
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_creating_project_site
    authorize current_user, :can_create_canvas_project_site?
  end

  # POST /api/academics/canvas/project_provision/create.json
  def create_project_site
    raise Errors::BadRequestError, 'Project site name must be no more than 255 characters in length' if params['name'].length > 255
    worker = Canvas::ProjectProvision.new(session['user_id'])
    course_details = worker.create_project(params['name'])
    render json: course_details.to_json
  end
end
