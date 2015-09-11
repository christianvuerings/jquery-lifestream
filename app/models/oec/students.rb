module Oec
  class Students < Worksheet

    def headers
      %w(
        LDAP_UID
        SIS_ID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
      )
    end

  end
end
