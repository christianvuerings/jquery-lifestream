class CanvasUserProvisionController < ApplicationController
  include ClassLogger

  before_filter :authenticate_admin!

  # POST /api/academics/canvas/user_provision/user_import.json
  def user_import
    user_ids = params[:user_ids].split(',')
    CanvasUserProvision.new.import_users(user_ids)
    render json: { status: 'success', user_ids: user_ids }.to_json
  rescue StandardError => error
    render error_response(error.message) and return
  end

  def authenticate_admin!
    user_id = session[:user_id]
    unless user_id.present?
      logger.warn("Bad request made to Canvas User Provision: No session user")
      render nothing: true, status: 401 and return
    end
    unless UserAuth.is_superuser?(user_id) || CanvasAdminsProxy.new.admin_user?(user_id)
      logger.warn("Bad request made to Canvas User Provision: session user = #{user_id}")
      render nothing: true, status: 401 and return
    end
  end

  def error_response(error_msg)
    { :json => { :status => 'error', :error => error_msg }.to_json }
  end

end
