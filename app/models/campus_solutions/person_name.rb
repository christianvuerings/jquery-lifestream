module CampusSolutions
  class PersonName < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:type, :NAME_TYPE),
          FieldMapping.required(:firstName, :FIRST_NAME),
          FieldMapping.required(:lastName, :LAST_NAME),
          FieldMapping.required(:initials, :NAME_INITIALS),
          FieldMapping.required(:prefix, :NAME_PREFIX),
          FieldMapping.required(:suffix, :NAME_SUFFIX),
          FieldMapping.required(:royalPrefix, :NAME_ROYAL_PREFIX),
          FieldMapping.required(:royalSuffix, :NAME_ROYAL_SUFFIX),
          FieldMapping.required(:title, :NAME_TITLE),
          FieldMapping.required(:middleName, :MIDDLE_NAME),
          FieldMapping.required(:secondLastName, :SECOND_LAST_NAME),
          FieldMapping.required(:ac, :NAME_AC),
          FieldMapping.required(:preferredFirstName, :PREF_FIRST_NAME),
          FieldMapping.required(:partnerLastName, :PARTNER_LAST_NAME),
          FieldMapping.required(:partnerRoyalPrefix, :PARTNER_ROY_PREFIX),
          FieldMapping.required(:lastNamePrefNld, :LAST_NAME_PREF_NLD)
        ]
      )
    end

    def request_root_xml_node
      'NAMES'
    end

    def xml_filename
      'person_name.xml'
    end

    def default_post_params
      super.merge(
        {
          COUNTRY_NM_FORMAT: '001'
        })
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_NAME.v1/name/post/"
    end

  end
end
