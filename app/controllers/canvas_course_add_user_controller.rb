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
    render json: {
      canvasRootUrl: Settings.canvas_proxy.url_root,
      courseId: canvas_course_id,
      roles: profile[:roles],
      roleTypes: profile[:roleTypes],
      grantingRoles: profile[:granting_roles_and_ids].keys
    }.to_json
  end

  # GET /api/academics/canvas/course_add_user/search_users.json
  def search_users
    raise Errors::BadRequestError, "Parameter 'searchText' is blank" if params['searchText'].blank?
    raise Errors::BadRequestError, "Parameter 'searchType' is invalid" unless CanvasLti::CourseAddUser::SEARCH_TYPES.include?(params['searchType'])
    users_found = CanvasLti::CourseAddUser.search_users(params['searchText'], params['searchType'])
    render json: { users: users_found }.to_json
  end

  # GET /api/academics/canvas/course_add_user/course_sections.json
  def course_sections
    sections_list = model.course_sections_list
    render json: { courseSections: sections_list }.to_json
  end

  # POST /api/academics/canvas/course_add_user/add_user.json
  def add_user
    authorize_section_id
    authorize_granted_role
    role_id = user_profile[:granting_roles_and_ids][params['role']]
    model.add_user_to_course_section(params['ldapUserId'], role_id, params['sectionId'])
    user_added = { :ldapUserId => params['ldapUserId'], :role => params['role'], :sectionId => params['sectionId'] }
    render json: { userAdded: user_added }.to_json
  end

  private

  def authorize_section_id
    sections_list = model.course_sections_list
    unless sections_list.index {|s| s['id'] == params['sectionId']}
      raise Pundit::NotAuthorizedError, "Section #{params['sectionId']} is not in course #{canvas_course_id}"
    end
  end

  def authorize_granted_role
    granted_role_ids = []
    if user_profile[:granting_roles_and_ids][params['role']].blank?
      raise Pundit::NotAuthorizedError, "Role specified is unauthorized: #{params['role']}"
    end
  end

  def model
    @model ||= CanvasLti::CourseAddUser.new(user_id: session['user_id'], canvas_course_id: canvas_course_id)
  end

  def user_profile
    @user_profile ||= model.authorization_profile
  end

end
