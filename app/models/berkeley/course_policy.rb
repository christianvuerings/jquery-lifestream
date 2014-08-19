module Berkeley
  # Pundit Policy used with Berkeley::Course to handle authorizations.
  # Used indirectly by #authorize helper provided by Pundit gem.
  class CoursePolicy
    include ClassLogger
    attr_reader :user, :record

    def initialize(user, record=nil)
      @user = user
      @record = record
    end

    def can_view_roster_photos?
      is_course_instructor?
    end

    def is_course_instructor?
      users_courses = CampusOracle::UserCourses::All.new({user_id: @user.user_id}).get_all_campus_courses
      record_course = users_courses.values.flatten.select {|c| c[:id] == @record.course_id }[0]
      return false if record_course.nil?
      if record_course[:role] != 'Instructor'
        logger.warn("Unauthorized request from user = #{@user.user_id} for Campus course #{@record.course_id}")
        return false
      end
      true
    end

  end
end
