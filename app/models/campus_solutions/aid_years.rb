module CampusSolutions
  class AidYears < DirectProxy

    def xml_filename
      'aid_years.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      "#{@settings.base_url}/UC_FA_GET_T_C.v1/get/EMPLID=00000165&INSTITUTION=UCB01"
    end

    def convert_feed_keys(feed)
      feed
    end

  end
end
