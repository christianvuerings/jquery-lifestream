module CampusSolutions
  class EmergencyContactDelete < DeletingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:contactName, :CONTACT_NAME)
        ]
      )
    end

    def xml_filename
      'emergency_contact_delete.xml'
    end

    def response_root_xml_node
      'EMERGENCY_CONTACT_DELETE_RESPONSE'
    end

    def url
      "#{@settings.base_url}/UC_CC_EMER_CNTCT.v1/emercntct/delete"
    end

  end
end
