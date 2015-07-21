module Calmail
  class AddListMember < Proxy
    include ClassLogger
    include ResponseWrapper

    ALREADY_A_MEMBER = 'APIv1 addMember: already a member'

    def add_member(list_name, email_address, full_name)
      handling_exceptions(list_name) do
        response = request('addMember', {
          body: {
            localpart: list_name,
            sub_address: email_address,
            fullname: full_name
          },
          on_error: {rescue_status: 500}
        })
        if response.code == 200
          added = true
        elsif response.code == 500 && response.parsed_response['message'] == ALREADY_A_MEMBER
          added = false
        else
          raise Errors::ProxyError.new("Error adding member #{email_address} to #{list_name}: #{response.body}", {response: response})
        end
        {
          email_address: email_address,
          added: added
        }
      end
    end

    def mock_json
      '{"tg_flash": null}'
    end

    def mock_response_already_a_member
      mock_response.merge(
        status: 500,
        body: "{\"tg_flash\": null, \"message\": \"#{ALREADY_A_MEMBER}\"}"
      )
    end

  end
end
