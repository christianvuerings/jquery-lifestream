module Oec
  class Supervisors < Oec::CsvExport

    def headers
      %w(
        LDAP_UID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        SUPERVISOR_GROUP
        PRIMARY_ADMIN
        SECONDARY_ADMIN
        DEPT_NAME_1
        DEPT_NAME_2
        DEPT_NAME_3
        DEPT_NAME_4
        DEPT_NAME_5
      )
    end

  end
end
