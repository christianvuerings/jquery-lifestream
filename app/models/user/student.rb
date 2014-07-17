module User
  module Student
    def lookup_student_id
      student = CampusOracle::UserAttributes.new(user_id: @uid).get_feed
      student.try(:[], "student_id")
    end
  end
end
