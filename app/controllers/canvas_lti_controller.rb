class CanvasLtiController < ApplicationController
  include ClassLogger
  include CanvasLti::ExternalAppConfigurations

  # Since LTI provider views are in an iframe, we need to skip the iframe buster.
  # Since the LTI session is initiated by a POST, to receive the request we also need to skip the CSRF check.
  before_filter :get_settings, :initialize_calcentral_config
  skip_before_action :verify_authenticity_token, :set_x_frame_options_header
  before_action :disable_xframe_options
  layout false
  helper_method :launch_url

  EMPTY_MASQUERADE_VALUE = '$Canvas.masqueradingUser.id'

  def authenticate
    logger.warn 'Unexpected no-op authenticate call!'
  end

  def authenticate_by_lti(lti)
    canvas_user_login_id = lti.get_custom_param 'canvas_user_login_id'
    canvas_user_id = lti.get_custom_param 'canvas_user_id'
    canvas_course_id = lti.get_custom_param 'canvas_course_id'
    canvas_masquerading_user_id = lti.get_custom_param 'canvas_masquerading_user_id'

    lti_user_properties = "UID #{canvas_user_login_id}, Canvas ID #{canvas_user_id}"
    lti_user_properties.prepend "Canvas ID #{canvas_masquerading_user_id} acting as " if canvas_masquerading_user_id != EMPTY_MASQUERADE_VALUE
    lti_user_properties << ", course ID #{canvas_course_id}" if canvas_course_id

    if !session['user_id']
      logger.debug "LTI user: (#{lti_user_properties}) has no existing CalCentral session"
      check_for_masquerade canvas_masquerading_user_id
    elsif session['user_id'] == lti.get_custom_param('canvas_user_login_id')
      logger.debug "LTI user: (#{lti_user_properties}) has existing CalCentral session: #{session_message}"
    else
      logger.error "LTI user: (#{lti_user_properties}) does not match existing CalCentral session; logging out: #{session_message}"
      reset_session
      check_for_masquerade canvas_masquerading_user_id
    end

    session['user_id'] = canvas_user_login_id
    session['canvas_user_id'] = canvas_user_id
    session['canvas_course_id'] = canvas_course_id
  end

  def check_for_masquerade(masquerading_user_id)
    if masquerading_user_id != EMPTY_MASQUERADE_VALUE
      session['canvas_masquerading_user_id'] = masquerading_user_id
      session['lti_authenticated_only'] = true
    end
  end

  def embedded
    lti = CanvasLti::Lti.new.validate_tool_provider(request)
    if lti
      authenticate_by_lti(lti)
      logger.warn "Session authenticated by LTI: #{session_message}"
      render 'public/bcourses_embedded.html'
    else
      logger.error 'Error parsing LTI request; returning error message'
      # TODO Test the result of a redirect or an error status return.
      render inline: '<html><body><p>The application cannot start. An error has been logged.</p></body></html>'
    end
  end

  # If no query parameters are present, returns a URL corresponding to the app server.
  # If 'app_host' is specified, then the URL points to the app_host server, which is assumed
  # to be a shared server behind https.
  # Example: https://calcentral.berkeley.edu/canvas/lti_roster_photos.xml?app_host=sometestsystem.berkeley.edu
  def launch_url(app_name)
    if (app_host = params['app_host'])
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
