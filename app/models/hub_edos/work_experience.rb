module HubEdos
  class WorkExperience < Proxy

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      initialize_mocks if @fake
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/work-experiences"
    end

    def xml_filename
      'work_experience.xml'
    end

    def build_feed(response)
      resp = parse_response response
      if resp['StudentResponse'].present? && resp['StudentResponse']['students'].present? && resp['StudentResponse']['students']['student'].present?
        {
          # yes, the array structure really is this weird.
          'workExperiences' => response.parsed_response['StudentResponse']['students']['student']['workExperiences']['workExperience']
        }
      else
        {}
      end
    end

    def request_options
      super.merge({on_error: {rescue_status: 404}})
    end

  end
end
