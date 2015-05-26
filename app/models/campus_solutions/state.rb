module CampusSolutions
  class State < DirectProxy

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

    def url
      "#{@settings.base_url}/UC_STATE_GET.v1/state/get"
    end

  end
end
