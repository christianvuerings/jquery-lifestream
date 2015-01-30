class AuthenticationStatePolicy
  attr_reader :user, :record

  # This Pundit policy class handles authorization decisions which depend solely upon the current user's
  # authentication state, equivalent to ApplicationController's "current_user". It should be used as the
  # superclass for all other Pundit policies.
  #
  # By design, it ignores the "@record" initialization parameter so that it can be reserved for use by
  # more specific Policy subclasses.
  def initialize(authentication_state, record)
    # Pundit convention is to store the current_user parameter in an instance variable named "@user".
    @user = authentication_state
    @record = record
  end

  def access_google?
    @user.directly_authenticated?
  end

  def can_administrate?
    @user.real_user_auth.active? && @user.real_user_auth.is_superuser? &&
      @user.user_auth.active? && @user.user_auth.is_superuser?
  end

  def can_administrate_canvas?
    can_administrate? || Canvas::Admins.new.admin_user?(@user.user_id)
  end

  def can_author?
    @user.real_user_auth.active? && (@user.real_user_auth.is_superuser? || @user.real_user_auth.is_author?)
  end

  def can_clear_campus_links_cache?
    can_clear_cache? || can_author?
  end

  def can_clear_cache?
    # Only super-users are allowed to clear caches in production, but in development mode, anyone can.
    !Rails.env.production? || can_administrate?
  end

  def can_create_canvas_project_site?
    can_administrate_canvas? || CampusOracle::UserAttributes.new(:user_id => @user.user_id).is_staff_or_faculty?
  end

  def can_create_canvas_course_site?
    can_administrate_canvas? || Canvas::CurrentTeacher.new(@user.user_id).user_currently_teaching?
  end

  def can_refresh_log_settings?
    # Only super-users are allowed to change logging settings in production, but in development mode, anyone can.
    !Rails.env.production? || can_administrate?
  end

  def can_view_as?
    @user.real_user_auth.active? && (@user.real_user_auth.is_superuser? || @user.real_user_auth.is_viewer?)
  end
end
