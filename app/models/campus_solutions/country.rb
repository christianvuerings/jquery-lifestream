module CampusSolutions
  class Country < DirectProxy

    def xml_filename
      'country.xml'
    end

    def build_feed(response)
      feed = {
        countries: []
      }
      return feed if response.parsed_response.blank?
      # TODO does front-end need to lookup by name/abbv, or is an array sufficient?
      response.parsed_response['UC_COUNTRY_GET_RESP']['COUNTRY_DETAILS'].each do |country|
        feed[:countries] << country
      end
      feed
    end

    def url
      "#{@settings.base_url}/UC_COUNTRY.v1/country/get"
    end

  end
end
