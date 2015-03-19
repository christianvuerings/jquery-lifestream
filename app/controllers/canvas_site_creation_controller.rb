class CanvasSiteCreationController < ApplicationController
  before_filter :api_authenticate
  rescue_from StandardError, with: :handle_api_exception

  # Serves feed determining access to course and project site creation tools
  def authorizations
    authorizations = Canvas::SiteCreation.new(:uid => session['user_id']).authorizations
    render :json => authorizations.to_json
  end
end
