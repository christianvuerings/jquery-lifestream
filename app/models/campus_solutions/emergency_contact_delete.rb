module CampusSolutions
  class EmergencyContactDelete < DeletingProxy

    include ProfileFeatureFlagged

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

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25738808'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_EMER_CNTCT.v1/emercntct/delete"
    end

  end
end
