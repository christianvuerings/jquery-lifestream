module Bearfacts
  class Profile < Proxy

    def mock_xml
      read_file('fixtures', 'xml', "bearfacts_profile_#{@student_id}.xml")
    end

    def request_path
      "/student/#{@student_id}"
    end

  end
end
