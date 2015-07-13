class CanvasCourseProvisionController < ApplicationController
  include ClassLogger
  include SpecificToCourseSite

  before_action :api_authenticate
  before_action :validate_admin_mode, :only => [:get_feed, :create_course_site]
  before_action :authorize_course_site_creation, only: [:get_feed, :create_course_site]
  before_action :authorize_official_sections_feed, only: [:get_sections_feed]
  before_action :authorize_official_sections_edit, only: [:edit_sections]
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_course_site_creation
    raise ArgumentError, 'Unexpected Canvas Course ID in request' if canvas_course_id.present?
    authorize current_user, :can_create_canvas_course_site?
  end
  def authorize_official_sections_feed
    raise ArgumentError, 'No Canvas Course ID in request' if canvas_course_id.blank?
    course = Canvas::Course.new(canvas_course_id: canvas_course_id)
    authorize course, :can_view_official_sections?
  end
  def authorize_official_sections_edit
    raise ArgumentError, 'No Canvas Course ID in request' if canvas_course_id.blank?
    course = Canvas::Course.new(canvas_course_id: canvas_course_id)
    authorize course, :can_edit_official_sections?
  end

  # GET /api/academics/canvas/course_provision.json
  # GET /api/academics/canvas/course_provision_as/:instructor_id.json
  def get_feed
    feed = Canvas::CourseProvision.new(session['user_id'], create_options_from_params).get_feed
    render json: feed.to_json
  end

  # POST /api/academics/canvas/course_provision/create.json
  def create_course_site
    worker = Canvas::CourseProvision.new(session['user_id'], create_options_from_params)
    # Since we expect the CCNs to have been provided by our own code rather than a human being,
    # we don't worry so much about invalid numbers.
    job_id = worker.create_course_site(params['siteName'], params['siteAbbreviation'], params['termSlug'], params['ccns'])
    render json: { job_request_status: "Success", job_id: job_id}.to_json
  end

  # GET /api/academics/canvas/course_provision/sections_feed/:canvas_course_id.json
  def get_sections_feed
    feed = Canvas::CourseProvision.new(session['user_id'], canvas_course_id: canvas_course_id).get_feed
    render json: feed.to_json
  end

  # POST /api/academics/canvas/course_provision/edit_sections/:canvas_course_id?ccns_to_add=:ccns_to_add&ccns_to_remove=:ccns_to_remove
  def edit_sections
    worker = Canvas::CourseProvision.new(session['user_id'], canvas_course_id: canvas_course_id)
    job_id = worker.edit_sections(params['ccns_to_remove'], params['ccns_to_add'])
    render json: { job_request_status: "Success", job_id: job_id}.to_json
  end

  # GET /api/academics/canvas/course_provision/status.json
  def job_status
    background_job = BackgroundJob.find(params['jobId'])
    render json: background_job.background_job_report.to_json and return if background_job.is_a? CanvasCsv::ProvideCourseSite
    render json: { jobId: params['jobId'], jobStatus: "Error", error: "Unable to find course management job" }.to_json
  end

  def create_options_from_params
    params.select {|k, v| [
      'admin_acting_as',
      'admin_by_ccns',
      'admin_term_slug'
    ].include?(k)}.symbolize_keys
  end

  def validate_admin_mode
    if params['admin_acting_as'] || params['admin_by_ccns'] || params['admin_term_slug']
      authorize current_user, :can_administrate_canvas?
      if params['admin_acting_as'] && (params['admin_by_ccns'] || params['admin_term_slug'])
        logger.warn("Conflicting request parameters sent to Canvas Course Provision: session user = #{session['user_id']}, params = #{params.inspect}")
        raise ArgumentError, "Conflicting request parameters sent to Canvas Course Provision"
      end
    end
  end
end
