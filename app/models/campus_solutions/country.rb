module CampusSolutions
  class Country < DirectProxy

    def xml_filename
      'country.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_COUNTRY.v1/country/get"
    end

  end
end
