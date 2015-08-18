module CampusSolutions
  module Posts
    class Email < PostingProxy

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

      def root_xml_node
        'EMAIL_ADDRESS'
      end

      def xml_filename
        'posts/email.xml'
      end

      def default_post_params
        # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
        {
          EMPLID: '25738808'
        }
      end

      def url
        "#{@settings.base_url}/UC_CC_PERS_EMAIL.v1/email/post/"
      end

      def build_feed(response)
        response.parsed_response['PostResponse']
      end
    end
  end
end
