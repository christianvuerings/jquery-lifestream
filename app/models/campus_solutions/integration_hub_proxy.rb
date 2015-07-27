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

    def build_feed(response)
      #HTTParty won't parse automatically because the application/xml header is missing
      MultiXml.parse response.body
    end

  end
end
