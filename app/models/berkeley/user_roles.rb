module Berkeley
  module UserRoles
    extend self

    def roles_from_affiliations(affiliations)
      affiliations ||= ''
      {
        :student => affiliations.include?('STUDENT-TYPE-'),
        :registered => affiliations.include?('STUDENT-TYPE-REGISTERED'),
        :exStudent => affiliations.include?('STUDENT-STATUS-EXPIRED'),
        :faculty => affiliations.include?('EMPLOYEE-TYPE-ACADEMIC'),
        :staff => affiliations.include?('EMPLOYEE-TYPE-STAFF'),
        :guest => affiliations.include?('GUEST-TYPE-COLLABORATOR'),
        :concurrentEnrollmentStudent => affiliations.include?('AFFILIATE-TYPE-CONCURR ENROLL')
      }
    end

    def roles_from_campus_row(campus_row)
      roles = roles_from_affiliations(campus_row['affiliations'])
      roles[:expiredAccount] = (campus_row['person_type'] == 'Z')
      roles
    end
  end
end
