class CanvasUserProvisionController < ApplicationController
  include ClassLogger

  before_filter :api_authenticate
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # POST /api/academics/canvas/user_provision/user_import.json
  def user_import
    authorize(current_user, :can_administrate_canvas?)
    user_ids = params['userIds'].split(',')
    CanvasCsv::UserProvision.new.import_users(user_ids)
    render json: { status: 'success', userIds: user_ids }.to_json
  end

  def error_response(error_msg)
    { :json => { :status => 'error', :error => error_msg }.to_json }
  end

end
