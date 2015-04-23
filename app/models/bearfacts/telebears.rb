module Bearfacts
  class Telebears < Proxy

    def initialize(options = {})
      @term_id = options[:term_id] || 'FT'
      super(options)
    end

    def instance_key
      "#{@uid}-#{@term_id}"
    end

    def mock_xml
      read_file('fixtures', 'xml', "bearfacts_telebears_#{@student_id}_#{@term_id}.xml")
    end

    def request_params
      {academicTerm: @term_id}
    end

    def request_path
      "/student/#{@student_id}/reg/appointments"
    end

  end
end
