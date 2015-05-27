class CanvasMailingListsController < ApplicationController
  include ClassLogger
  include SpecificToCourseSite

  before_action :api_authenticate
  before_action :authorize_mailing_list_administration

  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_mailing_list_administration
    authorize current_user, :can_administrate_canvas?
  end

  # GET /api/academics/canvas/mailing_lists/:canvas_course_id

  def show
    list = MailingLists::SiteMailingList.find_or_initialize_by canvas_site_id: canvas_course_id.to_s
    render json: list.to_json
  end

  # POST /api/academics/canvas/mailing_lists/:canvas_course_id/create

  def create
    list = MailingLists::SiteMailingList.create canvas_site_id: canvas_course_id.to_s, list_name: params['listName']
    render json: list.to_json
  end

  # POST /api/academics/canvas/mailing_lists/:canvas_course_id/populate

  def populate
    if (list = MailingLists::SiteMailingList.find_by canvas_site_id: canvas_course_id.to_s)
      list.populate
      render json: list.to_json
    else
      raise Errors::BadRequestError, "Bad course site ID #{canvas_course_id}"
    end
  end

 # POST /api/academics/canvas/mailing_lists/:canvas_course_id/delete

  def destroy
    if (list = MailingLists::SiteMailingList.find_by canvas_site_id: canvas_course_id.to_s)
      render json: {success: list.destroy}
    else
      raise Errors::BadRequestError, "Bad course site ID #{canvas_course_id}"
    end
  end

end
