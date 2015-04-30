class CanvasCourseGradeExportController < ApplicationController
  include SpecificToCourseSite

  before_action :api_authenticate_401, :except => [:is_official_course]
  before_action :authorize_exporting_grades, :except => [:is_official_course]
  before_action :disable_xframe_options, :only => [:download_egrades_csv]
  skip_before_action :set_x_frame_options_header
  rescue_from StandardError, with: :handle_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_exporting_grades
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in session or parameters" if canvas_course_id.blank?
    authorize canvas_course, :can_export_grades?
  end

  # POST /api/academics/canvas/egrade_export/prepare/:canvas_course_id.json
  def prepare_grades_cache
    egrades_worker = Canvas::Egrades.new(:canvas_course_id => canvas_course_id, :enable_grading_scheme => !!params['enableGradingScheme'], :unmute_assignments => !!params['unmuteAssignments'])
    egrades_worker.background_job_initialize
    egrades_worker.background.canvas_course_student_grades(true)
    render json: { jobRequestStatus: 'Success', jobId: egrades_worker.background_job_id }.to_json
  end

  # GET /api/academics/canvas/egrade_export/status/:canvas_course_id.json?jobId=Canvas::BackgroundJob.1383330151057-67f4b934525501cb
  def job_status
    background_job = Canvas::BackgroundJob.find(params['jobId'])
    render json: background_job.background_job_report.to_json and return if background_job.class == Canvas::Egrades
    render json: { jobId: params['jobId'], jobStatus: 'Error', errors: ['Unable to find Canvas::EGrades background job'] }.to_json
  end

  # GET /api/academics/canvas/egrade_export/download/:canvas_course_id.csv
  def download_egrades_csv
    raise Errors::BadRequestError, "term_cd required" unless params['term_cd']
    raise Errors::BadRequestError, "term_yr required" unless params['term_yr']
    raise Errors::BadRequestError, "ccn required" unless params['ccn']
    raise Errors::BadRequestError, "type required" unless params['type']
    raise Errors::BadRequestError, "invalid value for 'type' parameter" unless Canvas::Egrades::GRADE_TYPES.include?(params['type'])
    egrades_worker = Canvas::Egrades.new(:canvas_course_id => canvas_course_id)
    official_student_grades = egrades_worker.official_student_grades_csv(params['term_cd'], params['term_yr'], params['ccn'], params['type'])
    term_season = {
      'B' => 'Spring',
      'C' => 'Summer',
      'D' => 'Fall'
    }[params['term_cd']]
    respond_to do |format|
      format.csv { render csv: official_student_grades.to_s, filename: "egrades-#{params['type']}-#{params['ccn']}-#{term_season}-#{params['term_yr']}-#{canvas_course_id}" }
    end
  end

  def export_options
    egrades_worker = Canvas::Egrades.new(:canvas_course_id => canvas_course_id.to_i)
    export_options_json = egrades_worker.export_options.to_json
    render json: export_options_json
  end

  before_filter :set_cross_origin_access_control_headers, :only => [:is_official_course]
  def set_cross_origin_access_control_headers
    headers['Access-Control-Allow-Origin'] = "#{Settings.canvas_proxy.url_root}"
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def is_official_course
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in params" if params['canvas_course_id'].blank?
    official_course_worker = Canvas::OfficialCourse.new(:canvas_course_id => params['canvas_course_id'])
    render json: { :isOfficialCourse => official_course_worker.is_official_course? }.to_json
  end

  private

  def canvas_course
    canvas_course = Canvas::Course.new(:canvas_course_id => canvas_course_id.to_i)
  end

end
