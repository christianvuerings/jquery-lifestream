class CanvasController < ApplicationController
  include ClassLogger

  include Canvas::AuthorizationHelpers
  before_filter :authenticate_cas_user!, :only => [:course_user_profile]
  before_filter :authenticate_canvas_user!, :only => [:course_user_profile]
  before_filter :authenticate_canvas_course_user!, :only => [:course_user_profile]
  before_filter :set_cross_origin_access_control_headers, :only => [:external_tools]
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from StandardError, with: :handle_api_exception

  # Used to obtain LTI user in context of course embedded apps
  # GET /api/academics/canvas/course_user_profile
  def course_user_profile
    canvas_user_id = Integer(session[:canvas_user_id], 10)
    canvas_course_id = Integer(session[:canvas_course_id], 10)
    render json: { course_user_profile: @canvas_course_user }.to_json
  end

  # Provides data on LTI applications configured in Canvas
  def external_tools
    render json: Canvas::ExternalTools.new.public_list.to_json
  end

  def set_cross_origin_access_control_headers
    headers['Access-Control-Allow-Origin'] = "#{Settings.canvas_proxy.url_root}"
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS, HEAD'
    headers['Access-Control-Max-Age'] = '86400'
  end
end
