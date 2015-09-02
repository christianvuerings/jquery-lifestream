module CampusSolutions
  class EthnicitySetup < DirectProxy

    include ProfileFeatureFlagged

    def xml_filename
      'ethnicity_setup.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_SS_ETH_SETUP.v1/GetEthnicitytype/"
    end

  end
end
