module Oec
  class DiffReport < Worksheet

    def headers
      %w(
        +/-
        DEPT_CODE
        KEY
        LDAP_UID
        sis:COURSE_NAME
        COURSE_NAME
        sis:FIRST_NAME
        FIRST_NAME
        sis:LAST_NAME
        LAST_NAME
        sis:EMAIL_ADDRESS
        EMAIL_ADDRESS
        sis:DEPT_FORM
        DEPT_FORM
        sis:EVALUATION_TYPE
        EVALUATION_TYPE
        sis:MODULAR_COURSE
        MODULAR_COURSE
        sis:START_DATE
        START_DATE
        sis:END_DATE
        END_DATE
      )
    end

  end
end
