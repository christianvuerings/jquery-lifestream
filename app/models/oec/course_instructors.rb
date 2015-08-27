module Oec
  class CourseInstructors < Oec::CsvExport

    def headers
      %w(
        COURSE_ID
        LDAP_UID
        INSTRUCTOR_FUNC
      )
    end

  end
end
