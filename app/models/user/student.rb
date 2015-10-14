module User
  module Student
    def lookup_student_id
      student = CampusOracle::UserAttributes.new(user_id: @uid).get_feed
      student.try(:[], "student_id")
    end

    def lookup_campus_solutions_id
      CalnetCrosswalk::Proxy.new(user_id: @uid).lookup_campus_solutions_id
    end

    def lookup_student_id_from_crosswalk
      CalnetCrosswalk::Proxy.new(user_id: @uid).lookup_student_id
    end
  end
end
