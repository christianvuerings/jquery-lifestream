module Bearfacts
  class Regblocks < Proxy

    def get
      request("/student/#{lookup_student_id}/reg/regblocks", "regblocks")
    end

  end
end
