module Calmail
  class RemoveListMember < Proxy
    include ClassLogger
    include ResponseWrapper

    NOT_A_MEMBER = 'Not a member of the list'

    def remove_member(list_name, email_address)
      handling_exceptions(list_name) do
        response = request('removeMember', {
          body: {
            localpart: list_name,
            unsub_address: email_address,
            notify_owner: false,
            send_ack: false,
          },
          on_error: {rescue_status: 500}
        })
        if response.code == 200
          removed = true
        elsif response.code == 500 && response.parsed_response['message'] == NOT_A_MEMBER
          removed = false
        else
          raise Errors::ProxyError.new("Error removing member #{email_address} from #{list_name}: #{response.body}", {response: response})
        end
        {
          email_address: email_address,
          removed: removed
        }
      end
    end

    def mock_json
      '{"tg_flash": null}'
    end

    def mock_response_not_a_member
      mock_response.merge(
        status: 500,
        body: "{\"tg_flash\": null, \"message\": \"#{NOT_A_MEMBER}\"}"
      )
    end

  end
end
