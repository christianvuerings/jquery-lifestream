module HubEdos
  class WorkExperience < Proxy

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
      {
        # yes, the array structure really is this weird.
        'workExperiences' => response.parsed_response['studentResponse']['students']['students'][0]['workExperiences']['workExperiences']
      }
    end

  end
end
