module CampusSolutions
  class Address < DirectProxy

    def self.field_mappings
      mappings = [
        FieldMapping.required(:country, :COUNTRY),
        FieldMapping.required(:address1, :ADDRESS1),
        FieldMapping.optional(:address2, :ADDRESS2),
        FieldMapping.optional(:address3, :ADDRESS3),
        FieldMapping.optional(:address4, :ADDRESS4),
        FieldMapping.optional(:city, :CITY),
        FieldMapping.optional(:state, :STATE),
        FieldMapping.optional(:postal, :POSTAL)
      ]
      @field_mappings ||= FieldMapping.to_hash mappings
    end

    def xml_filename
      'address.xml'
    end

    def build_feed(response)
      feed = {
        addresses: [],
        fields: Address.field_mappings
      }
      return feed if response.parsed_response.blank?
      response.parsed_response['UC_PER_ADDR_GET_RESP']['ADDRESS'].each do |address|
        feed[:addresses] << address
      end
      feed
    end

    def url
      "#{@settings.base_url}/UC_PER_ADDR_GET.v1/person/address/get/?EMPLID=00000176"
    end

    def post(params = {})
      updateable_params = filter_updateable_params params
      logger.debug "Updateable params from POST: #{updateable_params.inspect}"
      cs_post = construct_cs_post updateable_params
      logger.debug "CS Post: #{cs_post}"
      {
        updated: true,
        updatedFields: updateable_params
      }
    end

    # lets us restrict updated params to what's on the whitelist of field mappings.
    def filter_updateable_params(params)
      updateable = {}
      known_fields = Address.field_mappings
      params.keys.each do |param_name|
        if known_fields[param_name.to_sym].present?
          updateable[param_name.to_sym] = params[param_name]
        end
      end
      updateable
    end

    def construct_cs_post(filtered_params)
      cs_post = {}
      filtered_params.keys.each do |calcentral_param_name|
        cs_param_name = Address.field_mappings[calcentral_param_name][:campus_solutions_name]
        cs_post[cs_param_name] = filtered_params[calcentral_param_name]
      end
      cs_post
    end

  end
end
