module CampusSolutions
  class EmergencyContact < PostingProxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:contactName, :CONTACT_NAME),
          FieldMapping.required(:isSameAddressEmpl, :SAME_ADDRESS_EMPL),
          FieldMapping.required(:isPrimaryContact, :PRIMARY_CONTACT),
          FieldMapping.required(:country, :COUNTRY),
          FieldMapping.required(:address1, :ADDRESS1),
          FieldMapping.required(:address2, :ADDRESS2),
          FieldMapping.required(:address3, :ADDRESS3),
          FieldMapping.required(:address4, :ADDRESS4),
          FieldMapping.required(:city, :CITY),
          FieldMapping.required(:num1, :NUM1),
          FieldMapping.required(:num2, :NUM2),
          FieldMapping.required(:houseType, :HOUSE_TYPE),
          FieldMapping.required(:addrField1, :ADDR_FIELD1),
          FieldMapping.required(:addrField2, :ADDR_FIELD2),
          FieldMapping.required(:addrField3, :ADDR_FIELD3),
          FieldMapping.required(:county, :COUNTY),
          FieldMapping.required(:state, :STATE),
          FieldMapping.required(:postal, :POSTAL),
          FieldMapping.required(:geoCode, :GEO_CODE),
          FieldMapping.required(:inCityLimit, :IN_CITY_LIMIT),
          FieldMapping.required(:countryCode, :COUNTRY_CODE),
          FieldMapping.required(:phone, :PHONE),
          FieldMapping.required(:relationship, :RELATIONSHIP),
          FieldMapping.required(:isSamePhoneEmpl, :SAME_PHONE_EMPL),
          FieldMapping.required(:addressType, :ADDRESS_TYPE),
          FieldMapping.required(:phoneType, :PHONE_TYPE),
          FieldMapping.required(:extension, :EXTENSION),
          FieldMapping.required(:emailAddr, :EMAIL_ADDR)
        ]
      )
    end

    def request_root_xml_node
      'UC_EMER_CNTCT'
    end

    def xml_filename
      'emergency_contact.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25738808'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_EMER_CNTCT.v1/emercntct/post/"
    end

  end
end
