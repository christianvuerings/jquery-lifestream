class CanvasController < ApplicationController
  include ClassLogger

  before_filter :set_cross_origin_access_control_headers, :only => [:external_tools, :user_can_create_course_site]
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error

  def set_cross_origin_access_control_headers
    headers['Access-Control-Allow-Origin'] = "#{Settings.canvas_proxy.url_root}"
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS, HEAD'
    headers['Access-Control-Max-Age'] = '86400'
  end

  # Provides data on LTI applications configured in Canvas
  # GET /api/academics/canvas/external_tools
  def external_tools
    render json: Canvas::ExternalTools.new.public_list_as_json
  end

  # Indicates if a Canvas user is authorized to provision course sites
  # GET /api/academics/canvas/user_can_create_course_site
  def user_can_create_course_site
    authorization = Canvas::PublicAuthorizer.new(params[:canvas_user_id]).can_create_course_site?
    render json: {'canCreateCourseSite' => authorization}.to_json
  end
end
