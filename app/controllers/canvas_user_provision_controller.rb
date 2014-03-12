class CanvasUserProvisionController < ApplicationController
  include ClassLogger

  # POST /api/academics/canvas/user_provision/user_import.json
  def user_import
    authorize(current_user, :can_import_canvas_users?)
    user_ids = params[:user_ids].split(',')
    Canvas::CanvasUserProvision.new.import_users(user_ids)
    render json: { status: 'success', user_ids: user_ids }.to_json
  rescue Pundit::NotAuthorizedError
    return user_not_authorized
  rescue StandardError => error
    render error_response(error.message) and return
  end

  def error_response(error_msg)
    { :json => { :status => 'error', :error => error_msg }.to_json }
  end

end
