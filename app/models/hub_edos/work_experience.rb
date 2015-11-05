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

    def json_filename
      'work_experience.json'
    end

    def build_feed(response)
      resp = parse_response response
      if resp['studentResponse'].present? && resp['studentResponse']['students'].present? && resp['studentResponse']['students'].length > 0
        {
          # yes, the array structure really is this weird.
          'workExperiences' => response.parsed_response['studentResponse']['students']['students'][0]['workExperiences']['workExperiences']
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
