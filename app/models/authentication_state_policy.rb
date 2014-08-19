class AuthenticationStatePolicy
  attr_reader :user, :record

  # This assumes that the @user instance variable (ApplicationController's "current_user") is an
  # AuthenticationState. By default, the @record is ignored here and reserved for use by Policy subclasses.
  def initialize(user, record)
    @user = user
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
