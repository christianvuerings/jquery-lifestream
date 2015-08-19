module Oec
  class CourseSupervisors < Oec::CsvExport

    def headers
      %w(
        COURSE_ID
        LDAP_UID
        DEPT_NAME
      )
    end

  end
end
