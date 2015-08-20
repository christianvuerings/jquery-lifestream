module CampusSolutions
  class Phone < PostingProxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

#     <?xml version="1.0"?>
#       <PERSON_PHONE>
#     <EMPLID>10120603</EMPLID>
# <PHONE_TYPE>CELL</PHONE_TYPE>
#     <COUNTRY_CODE>91</COUNTRY_CODE>
# <PHONE>9949919892</PHONE>
#     <EXTENSION>23</EXTENSION>
# <PREF_PHONE_FLAG>N</PREF_PHONE_FLAG>
#     </PERSON_PHONE>

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:type, :PHONE_TYPE),
          FieldMapping.required(:countryCode, :COUNTRY_CODE),
          FieldMapping.required(:phone, :PHONE),
          FieldMapping.required(:extension, :EXTENSION),
          FieldMapping.required(:isPreferred, :PREF_PHONE_FLAG)
        ]
      )
    end

    def request_root_xml_node
      'PERSON_PHONE'
    end

    def xml_filename
      'phone.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25738808'
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_PHONE.v1/phone/post/"
    end

  end
end
