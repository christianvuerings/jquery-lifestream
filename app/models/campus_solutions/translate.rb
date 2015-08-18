module CampusSolutions
  class Translate < DirectProxy

    def initialize(options = {})
      super options
      @field_name = options[:field_name]
      initialize_mocks if @fake
    end

    def xml_filename
      'translate.xml'
    end

    def instance_key
      @field_name
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CM_XLAT_VALUES.v1/GetXlats?FIELDNAME=#{@field_name}"
    end

  end
end
