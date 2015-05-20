module CampusSolutions
  class Country < Proxy

    def initialize(options = {})
      super(Settings.cs_country_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'cs_country.xml'
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

  end
end
