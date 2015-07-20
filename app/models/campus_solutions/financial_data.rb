module CampusSolutions
  class FinancialData < DirectProxy

    def xml_filename
      'financial_data.xml'
    end

    def build_feed(response)
      feed = {}
      return feed if response.parsed_response.blank?

      feed[:coa] = response.parsed_response['coa']
      feed
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      "#{@settings.base_url}/UC_FA_GET_T_C.v1/get/EMPLID=00000165&INSTITUTION=UCB01"
    end

  end
end
