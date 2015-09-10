module Oec
  class CourseInstructors < Worksheet

    def headers
      %w(
        COURSE_ID
        LDAP_UID
        INSTRUCTOR_FUNC
      )
    end

  end
end
