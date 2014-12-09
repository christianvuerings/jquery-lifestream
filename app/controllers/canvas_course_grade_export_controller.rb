class CanvasCourseGradeExportController < ApplicationController

  before_action :api_authenticate_401, :except => [:is_official_course]
  before_action :authorize_exporting_grades, :except => [:is_official_course]
  before_action :disable_xframe_options, :only => [:download_egrades_csv]
  skip_before_action :set_x_frame_options_header
  rescue_from StandardError, with: :handle_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_exporting_grades
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in session" if session[:canvas_course_id].blank?
    authorize canvas_course, :can_export_grades?
  end

  # GET /api/academics/canvas/egrade_export/download.csv
  def download_egrades_csv
    raise Errors::BadRequestError, "term_cd required" unless params[:term_cd]
    raise Errors::BadRequestError, "term_yr required" unless params[:term_yr]
    raise Errors::BadRequestError, "ccn required" unless params[:ccn]
    raise Errors::BadRequestError, "type required" unless params[:type]
    raise Errors::BadRequestError, "invalid value for 'type' parameter" unless Canvas::Egrades::GRADE_TYPES.include?(params[:type])
    canvas_course_id = session[:canvas_course_id].to_i
    egrades_worker = Canvas::Egrades.new(:canvas_course_id => canvas_course_id)
    official_student_grades = egrades_worker.official_student_grades_csv(params[:term_cd], params[:term_yr], params[:ccn], params[:type])
    respond_to do |format|
      format.csv { render csv: official_student_grades.to_s, filename: "course_#{canvas_course_id}_grades" }
    end
  end

  def export_options
    course_settings_worker = Canvas::CourseSettings.new(:course_id => session[:canvas_course_id].to_i)
    course_settings = course_settings_worker.settings(:cache => false)
    grading_standard_enabled = course_settings['grading_standard_enabled']

    egrades_worker = Canvas::Egrades.new(:canvas_course_id => session[:canvas_course_id].to_i)
    course_sections = egrades_worker.official_sections
    section_terms = egrades_worker.section_terms
    render json: { :officialSections => course_sections, :gradingStandardEnabled => grading_standard_enabled, :sectionTerms => section_terms }.to_json
  end

  before_filter :set_cross_origin_access_control_headers, :only => [:is_official_course]
  def set_cross_origin_access_control_headers
    headers['Access-Control-Allow-Origin'] = "#{Settings.canvas_proxy.url_root}"
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def is_official_course
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in params" if params[:canvas_course_id].blank?
    egrades_worker = Canvas::Egrades.new(:canvas_course_id => params[:canvas_course_id])
    is_official_course = egrades_worker.is_official_course?
    render json: { :isOfficialCourse => is_official_course }.to_json
  end

  private

  def canvas_course
    canvas_course = Canvas::Course.new(:canvas_course_id => session[:canvas_course_id].to_i)
  end

end
