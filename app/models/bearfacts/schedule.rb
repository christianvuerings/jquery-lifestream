module Bearfacts
  class Schedule < Proxy

    def get
      request("/student/#{lookup_student_id}/reg/classschedule", "classschedule")
    end

  end
end
