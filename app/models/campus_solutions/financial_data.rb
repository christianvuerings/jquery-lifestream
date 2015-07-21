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
      # TODO parameterize aid-year
      "#{@settings.base_url}/UC_FA_COST_ATT.v1/EMPLID=00000137&INSTITUTION=UCB01&AID_YEAR=2016"
    end

    def convert_feed_keys(feed)
      feed
    end

  end
end
