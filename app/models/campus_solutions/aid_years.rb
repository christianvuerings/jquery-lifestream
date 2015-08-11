module CampusSolutions
  class AidYears < IntegrationHubProxy

    def initialize(options = {})
      super(Settings.cs_aid_years_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'aid_years.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      # TODO note strange form of EMPLID param syntax (this is a PS misconfig that should be fixed soon)
      "#{@settings.base_url}/UC_FA_GET_T_C.v1/get?EMPLID=25738808&INSTITUTION=UCB01"
    end

    def convert_feed_keys(feed)
      feed
    end

  end
end
