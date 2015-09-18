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

    validate('BLUE_ROLE') { |row| 'Invalid' if row['BLUE_ROLE'] != '23' }
    validate('LDAP_UID') { |row| 'Non-numeric' unless row['LDAP_UID'] =~ /\A\d+\Z/ }

  end
end
