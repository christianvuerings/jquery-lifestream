module CampusSolutions
  class Address < DirectProxy

    FIELD_MAPPINGS = [
      FieldMapping.required(:country, :COUNTRY),
      FieldMapping.required(:address1, :ADDRESS1),
      FieldMapping.optional(:address2, :ADDRESS2)
    ]

    def xml_filename
      'address.xml'
    end

    def build_feed(response)
      feed = {
        addresses: [],
        fields: FieldMapping.to_hash(FIELD_MAPPINGS)
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

  end
end
