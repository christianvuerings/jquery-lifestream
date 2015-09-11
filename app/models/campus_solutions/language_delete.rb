module CampusSolutions
  class LanguageDelete < DeletingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:jpmCatItemId, :JPM_CAT_ITEM_ID)
        ]
      )
    end

    def xml_filename
      'language_delete.xml'
    end

    def response_root_xml_node
      'LANGUAGES_DELETE_RESPONSE'
    end

    def url
      "#{@settings.base_url}/UC_CC_LANGUAGES.v1/languages/delete"
    end

  end
end
