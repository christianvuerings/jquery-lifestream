module Bearfacts
  class Profile < Proxy

    def get
      request("/student/#{lookup_student_id}", "profile")
    end

  end
end
