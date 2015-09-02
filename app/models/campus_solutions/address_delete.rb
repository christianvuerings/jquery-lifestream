module CampusSolutions
  class AddressDelete < DeletingProxy

    include ProfileFeatureFlagged

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
      'address_delete.xml'
    end

    def response_root_xml_node
      'ADDRESS_DELETE_RESPONSE'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25753380'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_ADDR.v1/Address/delete"
    end

  end
end
