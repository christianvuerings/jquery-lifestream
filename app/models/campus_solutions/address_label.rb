module CampusSolutions
  class AddressLabel < DirectProxy

    def initialize(options = {})
      super options
      @country = options[:country] || 'USA'
      initialize_mocks if @fake
    end

    def xml_filename
      'address_label.xml'
    end

    def instance_key
      @country
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_ADDR_LBL.v1/get?COUNTRY=#{@country}"
    end

  end
end
