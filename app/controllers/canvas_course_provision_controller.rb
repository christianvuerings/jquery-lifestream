class CanvasCourseProvisionController < ApplicationController
  include ClassLogger

  before_filter :api_authenticate
  before_filter :validate_admin_mode, :only => [:get_feed, :create_course_site]
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /api/academics/canvas/course_provision.json
  # GET /api/academics/canvas/course_provision_as/:instructor_id.json
  def get_feed
    if (feed = Canvas::CourseProvision.new(session[:user_id], options_from_params).get_feed)
      render json: feed.to_json
    else
      render nothing: true, status: 401
    end
  end

  # POST /api/academics/canvas/course_provision/create.json
  def create_course_site
    worker = Canvas::CourseProvision.new(session[:user_id], options_from_params)
    # Since we expect the CCNs to have been provided by our own code rather than a human being,
    # we don't worry so much about invalid numbers.
    job_id = worker.create_course_site(params[:siteName], params[:siteAbbreviation], params[:termSlug], params[:ccns])
    render json: { job_request_status: "Success", job_id: job_id}.to_json
  end

  # GET /api/academics/canvas/course_provision/status.json
  def job_status
    course_provision_job = Canvas::ProvideCourseSite.find(params[:job_id])
    render json: course_provision_job.to_json and return if course_provision_job.class == Canvas::ProvideCourseSite
    render json: { job_id: params[:job_id], status: "Error", error: "Unable to find course provisioning job" }.to_json
  end

  def options_from_params
    params['canvas_course_id'] ||= session[:canvas_course_id]
    params.select {|k, v| [
      'admin_acting_as',
      'admin_by_ccns',
      'admin_term_slug',
      'canvas_course_id'
    ].include?(k)}.symbolize_keys
  end

  def validate_admin_mode
    if params[:admin_acting_as] && (params[:admin_by_ccns] || params[:admin_term_slug])
      logger.warn("Conflicting request parameters sent to Canvas Course Provision: session user = #{session[:user_id]}, params = #{params.inspect}")
      raise ArgumentError, "Conflicting request parameters sent to Canvas Course Provision"
    end
  end
end
