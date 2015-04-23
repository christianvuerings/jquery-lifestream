module Bearfacts
  class Schedule < Proxy

    def mock_xml
      read_file('fixtures', 'xml', "bearfacts_schedule_#{@student_id}.xml")
    end

    def request_path
      "/student/#{@student_id}/reg/classschedule"
    end

  end
end
