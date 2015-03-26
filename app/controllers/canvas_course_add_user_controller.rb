class CanvasCourseAddUserController < ApplicationController
  include SpecificToCourseSite

  before_filter :api_authenticate
  before_filter :authorize_adding_user, :except => [:course_user_roles]
  rescue_from StandardError, with: :handle_api_exception
  rescue_from Errors::ClientError, with: :handle_client_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def authorize_adding_user
    course_id = canvas_course_id
    raise Pundit::NotAuthorizedError, "Canvas Course ID not present" if course_id.blank?
    canvas_course = Canvas::Course.new(:user_id => session['user_id'], :canvas_course_id => course_id)
    authorize canvas_course, :can_add_users?
  end

  # Used to obtain LTI user in context of course embedded apps
  # GET /api/academics/canvas/course_user_roles
  def course_user_roles
    profile = user_profile
    render json: { courseId: canvas_course_id, roles: profile[:roles], roleTypes: profile[:roleTypes], grantingRoles: profile[:grantingRoles] }.to_json
  end

  # GET /api/academics/canvas/course_add_user/search_users.json
  def search_users
    raise Errors::BadRequestError, "Parameter 'searchText' is blank" if params['searchText'].blank?
    raise Errors::BadRequestError, "Parameter 'searchType' is invalid" unless Canvas::CourseAddUser::SEARCH_TYPES.include?(params['searchType'])
    users_found = Canvas::CourseAddUser.search_users(params['searchText'], params['searchType'])
    render json: { users: users_found }.to_json
  end

  # GET /api/academics/canvas/course_add_user/course_sections.json
  def course_sections
    sections_list = Canvas::CourseAddUser.course_sections_list(canvas_course_id)
    render json: { courseSections: sections_list }.to_json
  end

  # POST /api/academics/canvas/course_add_user/add_user.json
  def add_user
    authorize_granted_role
    Canvas::CourseAddUser.add_user_to_course_section(params['ldapUserId'], params['roleId'], params['sectionId'])
    user_added = { :ldapUserId => params['ldapUserId'], :roleId => params['roleId'], :sectionId => params['sectionId'] }
    render json: { userAdded: user_added }.to_json
  end

  private

  def authorize_granted_role
    granted_role_ids = []
    user_profile[:grantingRoles].each {|role| granted_role_ids << role['id']}
    raise Pundit::NotAuthorizedError, "Role specified is unauthorized" unless granted_role_ids.include?(params['roleId'])
  end

  def user_profile
    canvas_user_profile = Canvas::SisUserProfile.new(user_id: session['user_id']).get
    course_user_worker = Canvas::CourseUser.new(:user_id => canvas_user_profile['id'], :course_id => canvas_course_id)
    course_user_roles = course_user_worker.roles
    course_user_role_types = course_user_worker.role_types
    global_admin = Canvas::Admins.new.admin_user?(session['user_id'])
    granting_roles = Canvas::CourseAddUser.granting_roles(course_user_roles, global_admin)
    { roles: course_user_roles.merge({'globalAdmin' => global_admin}), roleTypes: course_user_role_types, grantingRoles: granting_roles }
  end

end
