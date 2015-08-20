module CampusSolutions
  class Title4 < PostingProxy

    include IntegrationHubProxy

    def initialize(options = {})
      super(Settings.cs_title4_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:response, :UC_RESPONSE)
        ]
      )
    end

    def request_root_xml_node
      'Title4'
    end

    def response_root_xml_node
      'UC_FA_TITL4_RSP'
    end

    def xml_filename
      'title4.xml'
    end

    def default_post_params
      # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
      {
        EMPLID: '25738808',
        INSTITUTION: 'UCB01',
        LASTUPDOPRID: '1086132'
      }
    end

    def url
      "#{@settings.base_url}/UC_FA_TITL4.v1/post"
    end

  end
end
