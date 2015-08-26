module CampusSolutions
  class WorkExperience < PostingProxy

    include ProfileFeatureFlagged

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:extOrganizationId, :EXT_ORGNIZATION_ID),
          FieldMapping.required(:isRetired, :IS_RETIRED),
          FieldMapping.required(:workExpAddrType, :WORK_EXP_ADDR_TYPE),
          FieldMapping.required(:country, :COUNTRY),
          FieldMapping.required(:addressType, :ADDRESS_TYPE),
          FieldMapping.required(:city, :CITY),
          FieldMapping.required(:state, :STATE),
          FieldMapping.required(:phoneType, :PHONE_TYPE),
          FieldMapping.required(:phone, :PHONE),
          FieldMapping.required(:startDt, :START_DT),
          FieldMapping.required(:endDt, :END_DT),
          FieldMapping.required(:retirementDt, :RETIREMENT_DT),
          FieldMapping.required(:titleLong, :TITLE_LONG),
          FieldMapping.required(:employFrac, :EMPLOY_FRAC),
          FieldMapping.required(:hoursPerWeek, :HOURS_PER_WEEK),
          FieldMapping.required(:endingPayRate, :ENDING_PAY_RATE),
          FieldMapping.required(:currencyCd, :CURRENCY_CD),
          FieldMapping.required(:payFrequency, :PAY_FREQUENCY)

        ]
      )
    end

    def request_root_xml_node
      'Prior_Work_Exp'
    end

    def response_root_xml_node
      'PriorWork'
    end

    def xml_filename
      'work_experience.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '13320458'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_PRIOR_WORK_EXP.v1/post/"
    end

  end
end
