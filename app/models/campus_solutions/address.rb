module CampusSolutions
  class Address < Proxy

    def initialize(options = {})
      super(Settings.cs_address_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'address.xml'
    end

    def build_feed(response)
      feed = {
        addresses: []
      }
      return feed if response.parsed_response.blank?
      response.parsed_response['UC_PER_ADDR_GET_RESP']['ADDRESS'].each do |address|
        feed[:addresses] << address
      end
      feed
    end

  end
end
