module CampusSolutions
  class NameType < DirectProxy

    def xml_filename
      'name_type.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_NAME_TYPE.v1/getNameTypes/"
    end

  end
end
