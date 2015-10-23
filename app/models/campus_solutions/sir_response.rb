module CampusSolutions
  class SirResponse < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:acadCareer, :ACAD_CAREER),
          FieldMapping.required(:studentCarNbr, :STDNT_CAR_NBR),
          FieldMapping.required(:admApplNbr, :ADM_APPL_NBR),
          FieldMapping.required(:applProgNbr, :APPL_PROG_NBR),
          FieldMapping.required(:chklstItemCd, :CHKLST_ITEM_CD),
          FieldMapping.required(:actionReason, :ACTION_REASON),
          FieldMapping.required(:progAction, :PROG_ACTION),
          FieldMapping.required(:responseReason, :RESPONSE_REASON),
          FieldMapping.required(:responseDescription, :RESPONSE_DESCR)
        ]
      )
    end

    def request_root_xml_node
      'UC_AD_SIR'
    end

    def xml_filename
      'sir_response.xml'
    end

    def url
      "#{@settings.base_url}/UC_AD_SIR.v1/sir/post/"
    end

  end
end
