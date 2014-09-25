class CanvasCourseAddUserController < ApplicationController

  before_filter :api_authenticate
  before_filter :authorize_adding_user, :except => [:course_user_roles]
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_adding_user
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present in session" if session[:canvas_course_id].blank?
    canvas_course = Canvas::Course.new(:user_id => session[:user_id], :canvas_course_id => canvas_course_id)
    authorize canvas_course, :can_add_users?
  end

  # Used to obtain LTI user in context of course embedded apps
  # GET /api/academics/canvas/course_user_roles
  def course_user_roles
    profile = user_profile
    render json: { courseId: session[:canvas_course_id], roles: profile[:roles], grantingRoles: profile[:granting_roles] }.to_json
  end

  # GET /api/academics/canvas/course_add_user/search_users.json
  def search_users
    raise Errors::BadRequestError, "Parameter 'search_text' is blank" if params['search_text'].blank?
    raise Errors::BadRequestError, "Parameter 'search_type' is invalid" unless Canvas::CourseAddUser::SEARCH_TYPES.include?(params['search_type'])
    users_found = Canvas::CourseAddUser.search_users(params['search_text'], params['search_type'])
    render json: { users: users_found }.to_json
  end

  # GET /api/academics/canvas/course_add_user/course_sections.json
  def course_sections
    sections_list = Canvas::CourseAddUser.course_sections_list(canvas_course_id)
    render json: { course_sections: sections_list }.to_json
  end

  # POST /api/academics/canvas/course_add_user/add_user.json
  def add_user
    authorize_granted_role
    Canvas::CourseAddUser.add_user_to_course_section(params[:ldap_user_id], params[:role_id], params[:section_id])
    user_added = { :ldap_user_id => params[:ldap_user_id], :role_id => params[:role_id], :section_id => params[:section_id] }
    render json: { user_added: user_added }.to_json
  end

  private

  def authorize_granted_role
    granted_role_ids = []
    user_profile[:granting_roles].each {|role| granted_role_ids << role['id']}
    raise Pundit::NotAuthorizedError, "Role specified is unauthorized" unless granted_role_ids.include?(params[:role_id])
  end

  def user_profile
    canvas_user_profile = Canvas::SisUserProfile.new(user_id: session[:user_id]).get
    course_user_roles = Canvas::CourseUser.new(:user_id => canvas_user_profile['id'], :course_id => canvas_course_id).roles
    global_admin = Canvas::Admins.new.admin_user?(session[:user_id])
    granting_roles = Canvas::CourseAddUser.granting_roles(course_user_roles, global_admin)
    { roles: course_user_roles.merge({'globalAdmin' => global_admin}), granting_roles: granting_roles }
  end

  def canvas_course_id
    Integer(session[:canvas_course_id], 10)
  end

end
