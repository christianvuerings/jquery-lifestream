class CanvasCourseGradeExportController < ApplicationController

  before_filter :api_authenticate_401
  before_filter :authorize_exporting_grades
  rescue_from StandardError, with: :handle_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_exporting_grades
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in session" if session[:canvas_course_id].blank?
    authorize canvas_course, :can_export_grades?
  end

  def download_egrades_csv
    raise Errors::BadRequestError, "term_cd required" unless params[:term_cd]
    raise Errors::BadRequestError, "term_yr required" unless params[:term_yr]
    raise Errors::BadRequestError, "ccn required" unless params[:ccn]
    canvas_course_id = session[:canvas_course_id].to_i
    egrades_worker = Canvas::Egrades.new(:user_id => session[:user_id], :canvas_course_id => canvas_course_id)
    official_student_grades = egrades_worker.official_student_grades_csv(params[:term_cd], params[:term_yr], params[:ccn])
    respond_to do |format|
      format.csv { render csv: official_student_grades.to_s, filename: "course_#{canvas_course_id}_grades" }
    end
  end

  def export_options
    egrades_worker = Canvas::Egrades.new(:user_id => session[:user_id], :canvas_course_id => session[:canvas_course_id].to_i)
    course_sections = egrades_worker.official_sections
    grade_types_present = egrades_worker.grade_types_present
    section_terms = egrades_worker.section_terms
    render json: { :official_sections => course_sections, :grade_types_present => grade_types_present, :section_terms => section_terms }.to_json
  end

  private

  def canvas_course
    canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => session[:canvas_course_id].to_i)
  end

end
