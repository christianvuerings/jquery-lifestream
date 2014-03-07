module Bearfacts
  class Telebears < BearfactsProxy

    def get
      request("/student/#{lookup_student_id}/reg/appointments", "telebears", {academicTerm: "FT"})
    end

  end
end
