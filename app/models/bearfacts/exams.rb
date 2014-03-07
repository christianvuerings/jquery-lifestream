module Bearfacts
  class Exams < Proxy

    def get
      request("/student/#{lookup_student_id}/reg/finalexams", "finalexams")
    end

  end
end
