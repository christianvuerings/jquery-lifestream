module CampusSolutions
  class Email < PostingProxy

    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:type, :E_ADDR_TYPE),
          FieldMapping.required(:email, :EMAIL_ADDR),
          FieldMapping.required(:isPreferred, :PREF_EMAIL_FLAG)
        ]
      )
    end

    def request_root_xml_node
      'EMAIL_ADDRESS'
    end

    def xml_filename
      'email.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_PERS_EMAIL.v1/email/post/"
    end

  end
end
