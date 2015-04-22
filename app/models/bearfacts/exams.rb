module Bearfacts
  class Exams < Proxy

    def mock_xml
      read_file('fixtures', 'xml', "bearfacts_exams_#{@student_id}.xml")
    end

    def request_path
      "/student/#{@student_id}/reg/finalexams"
    end

  end
end
