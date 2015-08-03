module CampusSolutions
  class FinancialAidData < IntegrationHubProxy

    def initialize(options = {})
      super(Settings.cs_financial_aid_data_proxy, options)
      @aid_year = options[:aid_year] || '0'
      initialize_mocks if @fake
    end

    def instance_key
      "#{@uid}-#{@aid_year}"
    end

    def xml_filename
      'financial_aid_data.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response['root']
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      # TODO note strange form of EMPLID param syntax (this is a PS misconfig that should be fixed soon)
      "#{@settings.base_url}/UC_FA_FINANCIAL_AID_DATA.v1/get?EMPLID=00000137&INSTITUTION=UCB01&AID_YEAR=#{@aid_year}"
    end

    def convert_feed_keys(feed)
      feed
    end

  end
end
