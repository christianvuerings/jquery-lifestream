module Calmail
  class CheckNamespace < Proxy
    include ClassLogger
    include ResponseWrapper

    MAILING_LIST_EXISTS = 'Invalid: localpart: A mailing list by that name already exists'

    def name_available?(list_name)
      handling_exceptions(list_name) do
        response = check_namespace(list_name)
        if response.code == 200 && response.parsed_response['available']
          true
        elsif response.code == 500 && response.parsed_response['message'] == MAILING_LIST_EXISTS
          false
        else
          raise Errors::ProxyError.new("Error checking namespace: #{response.body}", {response: response})
        end
      end
    end

    def check_namespace(list_name)
      request('checkNamespace', {
        body: {
          localpart: list_name,
          uid: @settings.owner_uid
        },
        on_error: {rescue_status: 500}
      })
    end

    def mock_response_list_name_exists
      mock_response.merge(
        status: 500,
        body: "{\"tg_flash\": null, \"message\": \"#{MAILING_LIST_EXISTS}\"}"
      )
    end

    def mock_json
      '{"available": true, "tg_flash": null}'
    end

  end
end
