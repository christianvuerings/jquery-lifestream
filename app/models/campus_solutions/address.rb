module CampusSolutions
  class Address < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:country, :COUNTRY),
          FieldMapping.required(:addressType, :ADDRESS_TYPE),
          FieldMapping.required(:address1, :ADDRESS1),
          FieldMapping.required(:address2, :ADDRESS2),
          FieldMapping.required(:address3, :ADDRESS3),
          FieldMapping.required(:address4, :ADDRESS4),
          FieldMapping.required(:city, :CITY),
          FieldMapping.required(:county, :COUNTY),
          FieldMapping.required(:houseType, :HOUSE_TYPE),
          FieldMapping.required(:num1, :NUM1),
          FieldMapping.required(:num2, :NUM2),
          FieldMapping.required(:postal, :POSTAL),
          FieldMapping.required(:state, :STATE),
          FieldMapping.required(:addrField1, :ADDR_FIELD1),
          FieldMapping.required(:addrField2, :ADDR_FIELD2),
          FieldMapping.required(:addrField3, :ADDR_FIELD3)
        ]
      )
    end

    def request_root_xml_node
      'UC_CC_ADDR_UPD_REQ'
    end

    def response_root_xml_node
      'UC_CC_PERS_I_ADDR_POST'
    end

    def xml_filename
      'address.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_I_ADDR.v1/addr/post"
    end

  end
end
