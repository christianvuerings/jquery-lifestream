module CampusSolutions
  class LanguagePost < PostingProxy

    include ProfileFeatureFlagged

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:languageCode, :JPM_CAT_ITEM_ID),
          FieldMapping.required(:isNative, :NATIVE_LANGUAGE),
          FieldMapping.required(:isTranslateToNative, :TRANSLATETO_NATIVE),
          FieldMapping.required(:isTeachLanguage, :TEACH_LANGUAGE),
          FieldMapping.required(:speakProf, :SPEAK_PROF),
          FieldMapping.required(:readProf, :READ_PROF),
          FieldMapping.required(:teachLang, :TEACH_LANG)
        ]
      )
    end

    def request_root_xml_node
      'Languages'
    end

    def response_root_xml_node
      'Languages'
    end

    def xml_filename
      'language_post.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25753380'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_LANGUAGES.v1/languages/post/"
    end

  end
end
