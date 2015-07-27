module CampusSolutions
  class TermsAndConditions < PostingProxy

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:uc_response, :UC_RESPONSE),
          FieldMapping.required(:aid_year, :AID_YEAR)
        ]
      )
    end

    def xml_filename
      'terms_and_conditions.xml'
    end

    def url
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      "#{@settings.base_url}/UC_FA_T_C.v1/post/EMPLID=00000165&INSTITUTION=UCB01"
    end

  end
end
