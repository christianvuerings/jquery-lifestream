module Bearfacts
  class Telebears < Proxy

    def initialize(options = {})
      super(options)
      @term_id = options[:term_id] || 'FT'
    end

    def instance_key
      "#{@uid}-#{@term_id}"
    end

    def get
      request("/student/#{lookup_student_id}/reg/appointments", 'telebears', {academicTerm: @term_id})
    end

    def custom_vcr_matcher
      Proc.new do |a, b|
        a_uri = URI(a.uri).query
        b_uri = URI(b.uri).query
        if !a_uri.blank? && !b_uri.blank?
          a_param_hash = CGI::parse(a_uri)
          b_param_hash = CGI::parse(b_uri)
          a_param_hash['academicTerm'] == b_param_hash['academicTerm']
        else
          a_uri == b_uri
        end
      end
    end

  end
end
