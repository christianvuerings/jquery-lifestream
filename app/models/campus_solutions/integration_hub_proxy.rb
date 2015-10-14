module CampusSolutions
  module IntegrationHubProxy

    # TODO make year dynamic (default to current aid year)
    def request_options
      super.merge({
        query: {
          'app_id' => @settings.app_id,
          'app_key' => @settings.app_key
        }
      })
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}"
    end

  end
end
