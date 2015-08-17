module CampusSolutions
  class CurrencyCode < DirectProxy

    def xml_filename
      'currency_code.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_CURRENCY_CD.v1/Currency_Cd/Get"
    end

  end
end
