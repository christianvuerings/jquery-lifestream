module Oec
  class DiffReport < Worksheet

    def headers
      %w(
        +/-
        DEPT_CODE
        KEY
        LDAP_UID
        DB_COURSE_NAME
        COURSE_NAME
        DB_FIRST_NAME
        FIRST_NAME
        DB_LAST_NAME
        LAST_NAME
        DB_EMAIL_ADDRESS
        EMAIL_ADDRESS
        DB_INSTRUCTOR_FUNC
        INSTRUCTOR_FUNC
      )
    end

  end
end
