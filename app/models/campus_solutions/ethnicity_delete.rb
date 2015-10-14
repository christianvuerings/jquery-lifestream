module CampusSolutions
  class EthnicityDelete < DeletingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:ethnicGroupCode, :ETHNIC_GRP_CD),
          FieldMapping.required(:regRegion, :REG_REGION)
        ]
      )
    end

    def xml_filename
      'ethnicity_delete.xml'
    end

    def response_root_xml_node
      'ETHNICITY_DELETE_RESPONSE'
    end

    def url
      "#{@settings.base_url}/UC_CC_SS_ETH.v1/Ethnicity/delete"
    end

  end
end
