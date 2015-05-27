class CanvasLtiController < ApplicationController
  include ClassLogger
  include Canvas::ExternalAppConfigurations

  # Since LTI provider views are in an iframe, we need to skip the iframe buster.
  # Since the LTI session is initiated by a POST, to receive the request we also need to skip the CSRF check.
  before_filter :get_settings, :initialize_calcentral_config
  skip_before_action :verify_authenticity_token, :set_x_frame_options_header
  before_action :disable_xframe_options
  layout false
  helper_method :launch_url

  def authenticate
    logger.warn("Unexpected no-op authenticate call!")
  end

  def authenticate_by_lti(lti)
    lti_user_id = lti.get_custom_param('canvas_user_login_id')
    if (existing_user_id = session['user_id'])
      if existing_user_id != lti_user_id
        logger.error("LTI is authenticated as #{lti_user_id}; logging out existing CalCentral session for #{existing_user_id}")
        reset_session
        session['lti_authenticated_only'] = true
      else
        logger.debug("LTI user #{lti_user_id} already has a CalCentral session")
      end
    else
      session['lti_authenticated_only'] = true
      logger.debug("LTI user #{lti_user_id} was not already logged into CalCentral")
    end
    session['user_id'] = lti_user_id
    session['canvas_user_id'] = lti.get_custom_param('canvas_user_id')
    session['canvas_course_id'] = lti.get_custom_param('canvas_course_id')
  end

  def embedded
    lti = Canvas::Lti.new.validate_tool_provider(request)
    if lti
      authenticate_by_lti(lti)
      logger.warn("Session authenticated by LTI; user = #{session['user_id']}")
      render "public/bcourses_embedded.html"
    else
      logger.error("Error parsing LTI request; returning error message")
      # TODO Test the result of a redirect or an error status return.
      render inline: "<html><body><p>The application cannot start. An error has been logged.</p></body></html>"
    end
  end

  # If no query parameters are present, returns a URL corresponding to the app server.
  # If 'app_host' is specified, then the URL points to the app_host server, which is assumed
  # to be a shared server behind https.
  # Example: https://calcentral.berkeley.edu/canvas/lti_roster_photos.xml?app_host=sometestsystem.berkeley.edu
  def launch_url(app_name)
    if (app_host = params["app_host"])
      launch_url_for_host_and_code("https://#{app_host}", app_name)
    else
      url_for(only_path: false, action: 'embedded', url: app_name)
    end
  end

  def lti_xml_configuration
    xml_name = request.filtered_parameters['action']
    app_name = xml_name_to_app_code(xml_name)
    @launch_url_for_app = launch_url(app_name)
    respond_to :xml
  end

  def lti_roster_photos
    lti_xml_configuration
  end

  def lti_site_creation
    lti_xml_configuration
  end

  def lti_site_mailing_lists
    lti_xml_configuration
  end

  def lti_user_provision
    lti_xml_configuration
  end

  def lti_course_add_user
    lti_xml_configuration
  end

  def lti_course_mediacasts
    lti_xml_configuration
  end

  def lti_course_grade_export
    lti_xml_configuration
  end

  def lti_course_manage_official_sections
    lti_xml_configuration
  end

end
