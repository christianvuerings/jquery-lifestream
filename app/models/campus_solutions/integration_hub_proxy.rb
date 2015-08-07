module CampusSolutions
  class IntegrationHubProxy < Proxy

    # TODO make year dynamic (default to current aid year)
    def request_options
      {
        query: {
          'app_id' => @settings.app_id,
          'app_key' => @settings.app_key
        }
      }
    end

    # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
    def url
      "#{@settings.base_url}/00000137"
    end

  end
end
