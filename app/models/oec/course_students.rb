module Oec
  class CourseStudents < Worksheet

    def headers
      %w(
        COURSE_ID
        LDAP_UID
      )
    end

  end
end
