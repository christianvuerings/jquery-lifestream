module CampusSolutions
  class Language < DirectProxy

    def xml_filename
      'language.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_CC_LANGUAGES.v1/get/languages/"
    end

  end
end
