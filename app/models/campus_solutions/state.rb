module CampusSolutions
  class State < Proxy

    def initialize(options = {})
      super(Settings.cs_lookups_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'state.xml'
    end

    def build_feed(response)
      feed = {
        states: []
      }
      return feed if response.parsed_response.blank?
      # TODO does front-end need to lookup by name/abbv, or is an array sufficient?
      response.parsed_response['UC_STATE_GET_RESP']['STATE_DETAILS'].each do |state|
        feed[:states] << state
      end
      feed
    end

  end
end
