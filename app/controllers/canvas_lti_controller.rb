class CanvasLtiController < ApplicationController
  include ClassLogger

  # Since LTI provider views are in an iframe, we need to skip the iframe buster.
  # Since the LTI session is initiated by a POST, to receive the request we also need to skip the CSRF check.
  skip_before_filter :verify_authenticity_token, :set_x_frame_options_header
  layout 'application'

  def authenticate
    logger.warn("Unexpected no-op authenticate call!")
  end

  def authenticate_by_lti(lti)
    login_user_id = lti.get_custom_param('canvas_user_login_id')
    session[:user_id] = login_user_id
    session[:canvas_lti_params] = lti.to_params
  end

  def embedded
    lti = CanvasLti.new.validate_tool_provider(request)
    if lti
      authenticate_by_lti(lti)
      logger.warn("Session authenticated by LTI; user = #{session[:user_id]}")
      render
    else
      logger.error("Error parsing LTI request; returning error message")
      # TODO Test the result of a redirect or an error status return.
      render inline: "<html><body><p>The application cannot start. An error has been logged.</p></body></html>"
    end
  end

  def lti_roster_photos
    respond_to :xml
  end

  def lti_course_provision
    respond_to :xml
  end

  def  lti_user_provision
    respond_to :xml
  end

end
