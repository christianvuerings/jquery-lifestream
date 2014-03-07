module Bearfacts
  class Schedule < BearfactsProxy

    def get
      request("/student/#{lookup_student_id}/reg/classschedule", "classschedule")
    end

  end
end
