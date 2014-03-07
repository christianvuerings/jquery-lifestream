module Bearfacts
  class Profile < BearfactsProxy

    def get
      request("/student/#{lookup_student_id}", "profile")
    end

  end
end
