class CanvasCourseAddUserController < ApplicationController
  include CanvasControllerHelpers

  before_filter :authenticate_user!
  before_filter :authenticate_course_user!

  rescue_from StandardError, with: :internal_error

  # GET /api/academics/canvas/course_add_user/search_users.json
  def search_users
    respond_to_bad_api_request and return unless CanvasCourseUserProxy.is_course_admin?(@canvas_course_user)
    users_found = CanvasCourseAddUser.search_users(params['search_text'], params['search_type'])
    render json: { users: users_found }.to_json
  end

  # GET /api/academics/canvas/course_add_user/course_sections.json
  def course_sections
    respond_to_bad_api_request and return unless CanvasCourseUserProxy.is_course_admin?(@canvas_course_user)
    sections_list = CanvasCourseAddUser.course_sections_list(@canvas_course_id)
    render json: { course_sections: sections_list }.to_json
  end

  # POST /api/academics/canvas/course_add_user/add_user.json
  def add_user
    respond_to_bad_api_request and return unless CanvasCourseUserProxy.is_course_admin?(@canvas_course_user)
    CanvasCourseAddUser.add_user_to_course_section(params[:ldap_user_id], params[:role_id], params[:section_id])
    user_added = { :ldap_user_id => params[:ldap_user_id], :role_id => params[:role_id], :section_id => params[:section_id] }
    render json: { user_added: user_added }.to_json
  end

  def internal_error(error)
    respond_with_json_error(500, error.message) and return
  end

end
