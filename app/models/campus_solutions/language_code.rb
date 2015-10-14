module CampusSolutions
  class LanguageCode < DirectProxy

    include ProfileFeatureFlagged

    def xml_filename
      'language_code.xml'
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
