module User
  class AuthPolicy
    attr_reader :user, :record

    def initialize(user, record=nil)
      @user = user
      @record = record
    end

    def can_administrate?
      user.active? && user.is_superuser?
    end

    def can_clear_cache?
      # Only super-users are allowed to clear caches in production, but in development mode, anyone can.
      !Rails.env.production? || can_administrate?
    end

    def can_clear_campus_links_cache?
      can_clear_cache? || can_author?
    end

    def can_refresh_log_settings?
      # Only super-users are allowed to change logging settings in production, but in development mode, anyone can.
      !Rails.env.production? || can_administrate?
    end

    def can_act_as?
      can_administrate? || (user.active? && user.is_viewer?)
    end

    def can_author?
      can_administrate? || (user.active? && user.is_author?)
    end

    def can_import_canvas_users?
      can_administrate? || can_administrate_canvas?
    end

    def can_administrate_canvas?
      Canvas::Admins.new.admin_user?(user.uid)
    end

    def can_create_canvas_course_site?
      is_current_instructor = Canvas::CurrentTeacher.new(user.uid).user_currently_teaching?
      can_administrate? || can_administrate_canvas? || is_current_instructor
    end

  end
end
