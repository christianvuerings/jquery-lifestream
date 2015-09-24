module Oec
  class CourseConfirmation < Worksheet

    def export_name
      'Courses'
    end

    def headers
      %w(
        COURSE_ID
        COURSE_NAME
        CROSS_LISTED_FLAG
        CROSS_LISTED_NAME
        LDAP_UID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        INSTRUCTOR_FUNC
        EVALUATE
        DEPT_FORM
        EVALUATION_TYPE
        MODULAR_COURSE
        START_DATE
        END_DATE
      )
    end

    validate('LDAP_UID') { |row| 'Non-numeric' unless row['LDAP_UID'] =~ /\A\d+\Z/ }

  end
end
