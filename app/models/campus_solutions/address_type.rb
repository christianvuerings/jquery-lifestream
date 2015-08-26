module CampusSolutions
  class AddressType < DirectProxy

    include ProfileFeatureFlagged

    def xml_filename
      'address_type.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_ADDR_TYPE.v1/getAddressTypes/"
    end

  end
end
