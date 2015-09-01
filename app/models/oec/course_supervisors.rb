module Oec
  class CourseSupervisors < Worksheet

    def headers
      %w(
        COURSE_ID
        LDAP_UID
        DEPT_NAME
      )
    end

  end
end
