module CampusSolutions
  class EmailDelete < DeletingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:type, :TYPE)
        ]
      )
    end

    def xml_filename
      'email_delete.xml'
    end

    def response_root_xml_node
      'EMAIL_ADDRESS_DELETE_RESPONSE'
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_EMAIL.v1/email/delete"
    end

  end
end
