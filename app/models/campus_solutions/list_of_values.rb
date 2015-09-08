module CampusSolutions
  class ListOfValues < PostingProxy

    include ProfileFeatureFlagged

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:fieldName, :FIELDNAME),
          FieldMapping.required(:recordName, :RECORDNAME)
        ]
      )
    end

    def instance_key
      "#{@params[:fieldName]}-#{@params[:recordName]}"
    end

    def request_root_xml_node
      'SCC_LOV_REQ'
    end

    def response_root_xml_node
      'SCC_LOV_RESP'
    end

    def xml_filename
      'list_of_values.xml'
    end

    def default_post_params
      {
        LOVS: {
          LOV: {
            FIELDNAME: @params[:fieldName],
            RECORDNAME: @params[:recordName],
            LOVCONTEXT: ''
          }
        }
      }
    end

    def request_options
      cs_post = construct_cs_post params
      {
        method: :post,
        body: cs_post,
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        }}
    end

    def build_feed(response)
      # delivered Campus Solutions API does not give us the xml content-type header that
      # HTTParty needs for auto-parsing, so we must parse it ourselves.
      parsed = MultiXml.parse response.body
      if parsed[response_root_xml_node].present?
        # rearrange stupid CS XML (which we can't change, because delivered) into a proper array
        values = []
        parsed[response_root_xml_node]['LOVS']['LOV']['VALUES']['VALUE'].each do |value|
          values << value
        end
        {
          values: values
        }
      else
        parsed[error_response_root_xml_node]
      end
    end

    def url
      "#{@settings.base_url}/SCC_GET_LOV_R.v1/get/lovs?languageCd=ENG"
    end

  end
end
