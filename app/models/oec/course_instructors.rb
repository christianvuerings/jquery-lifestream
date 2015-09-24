module Oec
  class CourseInstructors < Worksheet

    def headers
      %w(
        COURSE_ID
        LDAP_UID
        INSTRUCTOR_FUNC
      )
    end

    validate('INSTRUCTOR_FUNC') { |row| 'Unexpected' unless %w(1 2 4).include? row['INSTRUCTOR_FUNC'] }

  end
end
