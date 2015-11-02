module CampusSolutions
  class AddressLabel < DirectProxy

    include ProfileFeatureFlagged

    def initialize(options = {})
      super options
      @country = options[:country]
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
      feed = response.parsed_response
      feed['LABELS'].each do |label|
        # downcase and camelize the values of the FIELD key
        label['FIELD'] = label['FIELD'].downcase.camelize(:lower)
      end
      feed
    end

    def url
      "#{@settings.base_url}/UC_CC_ADDR_LBL.v1/get?COUNTRY=#{@country}"
    end

  end
end
