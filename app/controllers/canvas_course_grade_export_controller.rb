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
    canvas_course_id = session[:canvas_course_id].to_i
    course_grades_csv = Canvas::CourseUsers.new(:user_id => session[:user_id], :course_id => session[:canvas_course_id].to_i).course_grades_csv
    respond_to do |format|
      format.csv { render csv: course_grades_csv, filename: "course_#{canvas_course_id}_grades" }
    end
  end

  private

  def canvas_course
    canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => session[:canvas_course_id].to_i)
  end

end
