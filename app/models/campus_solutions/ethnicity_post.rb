module CampusSolutions
  class EthnicityPost < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:regRegion, :REG_REGION),
          FieldMapping.required(:ethnicGroupCode, :ETHNIC_GRP_CD),
          FieldMapping.required(:isPrimary, :PRIMARY_INDICATOR),
          FieldMapping.required(:isHispanicLatino, :SCC_IS_HISP_LAT_Y),
          FieldMapping.required(:isAmiAln, :SCC_IS_AMI_ALN),
          FieldMapping.required(:isAsian, :SCC_IS_ASIAN),
          FieldMapping.required(:isBlackAfAm, :SCC_IS_BLK_AFAM),
          FieldMapping.required(:isHawPac, :SCC_IS_HAW_PAC),
          FieldMapping.required(:isWhite, :SCC_IS_WHITE),
          FieldMapping.required(:isEthnicityValidated, :ETH_VALIDATED)
        ]
      )
    end

    def request_root_xml_node
      'UC_CC_ETH_RQT'
    end

    def xml_filename
      'ethnicity_post.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_SS_ETH.v1/Ethnicity/post/"
    end

  end
end
