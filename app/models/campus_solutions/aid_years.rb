module CampusSolutions
  class AidYears < DirectProxy

    def xml_filename
      'aid_years.xml'
    end

    def build_feed(response)
      feed = {
        finaid_years: []
      }
      return feed if response.parsed_response.blank?

      response.parsed_response['finaidSummary']['finaidYear'].each do |aidyear|
        feed[:finaid_years] << aidyear
      end
      feed
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      "#{@settings.base_url}/UC_FA_GET_T_C.v1/get/EMPLID=00000165&INSTITUTION=UCB01"
    end

  end
end
