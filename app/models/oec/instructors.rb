module Oec
  class Instructors < Worksheet

    def headers
      %w(
        LDAP_UID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        BLUE_ROLE
      )
    end

  end
end
