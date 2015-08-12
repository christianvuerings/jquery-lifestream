module CampusSolutions
  class Address < PostingProxy

    include Cache::UserCacheExpiry

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:country, :COUNTRY),
          FieldMapping.required(:address1, :ADDRESS1),
          FieldMapping.optional(:address2, :ADDRESS2),
          FieldMapping.optional(:address3, :ADDRESS3),
          FieldMapping.optional(:address4, :ADDRESS4),
          FieldMapping.optional(:city, :CITY),
          FieldMapping.optional(:state, :STATE),
          FieldMapping.optional(:postal, :POSTAL),
          FieldMapping.optional(:address_type, :ADDRESS_TYPE),
          FieldMapping.optional(:address_type_descr, :ADDRESS_TYPE_DESCR)
        ]
      )
    end

    def xml_filename
      'address.xml'
    end

    def build_feed(response)
      feed = {
        addresses: [],
        fields: self.class.field_mappings
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
