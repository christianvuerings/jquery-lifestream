class CanvasController < ApplicationController
  include ClassLogger

  before_filter :set_cross_origin_access_control_headers, :only => [:external_tools]
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
    render json: Canvas::ExternalTools.new.public_list.to_json
  end

end
