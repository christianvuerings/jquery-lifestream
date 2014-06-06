# Pundit Policy used with Canvas::Course to handle authorizations. Used indirectly by #authorize helper provided by Pundit gem.
module Canvas
  class CoursePolicy
    include ClassLogger
    attr_reader :user, :record

    def initialize(user, record=nil)
      @user = user
      @record = record
    end

    def can_add_users?
      (is_canvas_user? && is_canvas_course_user? && is_canvas_course_admin?) || is_canvas_account_admin?
    end

    def can_view_course?
      is_canvas_course_user? || is_canvas_account_admin?
    end

    def is_canvas_user?
      if canvas_user_profile.blank?
        logger.warn "UID #{@user.uid} not found in Canvas, attempting authorization for Canvas Course ID #{@record.canvas_course_id}"
        return false
      end
      true
    end

    def is_canvas_account_admin?
      Canvas::Admins.new.admin_user?(@user.uid)
    end

    def is_canvas_course_teacher_or_assistant?
      is_canvas_course_teacher? || is_canvas_course_teachers_assistant?
    end

    def is_canvas_course_teacher?
      is_canvas_user? && Canvas::CourseUser.is_course_teacher?(canvas_course_user)
    end

    def is_canvas_course_teachers_assistant?
      is_canvas_user? && Canvas::CourseUser.is_course_teachers_assistant?(canvas_course_user)
    end

    def is_canvas_course_user?
      canvas_course_user.present?
    end

    def is_canvas_course_admin?
      Canvas::CourseUser.is_course_admin?(canvas_course_user)
    end

    private

    def canvas_user_profile
      Canvas::SisUserProfile.new(user_id: @user.uid).get
    end

    def canvas_course_user
      return false if canvas_user_profile.blank?
      Canvas::CourseUser.new(:user_id => canvas_user_profile['id'], :course_id => @record.canvas_course_id).course_user
    end

  end
end
