module CampusSolutions
  class Address < PostingProxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:addressType, :ADDRESS_TYPE),
          FieldMapping.required(:address1, :ADDRESS1),
          FieldMapping.required(:address2, :ADDRESS2),
          FieldMapping.required(:city, :CITY),
          FieldMapping.required(:state, :STATE),
          FieldMapping.required(:postal, :POSTAL),
          FieldMapping.required(:country, :COUNTRY)
        ]
      )
    end

    def root_xml_node
      'UC_CC_ADDR_UPD_REQ'
    end

    def xml_filename
      'address.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25738808',
        EFFDT: '2015-10-09' # TODO fix hardcode
      }
    end

    def url
      "#{@settings.base_url}/UC_PER_ADDR_UPD_POST.v1/address/post/"
    end

    def build_feed(response)
      response.parsed_response['UC_PER_ADDR_UPD_POST_RESP']
    end
  end
end
