module Calmail
  class ListMembers < Proxy
    include ClassLogger
    include ResponseWrapper

    def list_members(list_name)
      handling_exceptions(list_name) do
        response = get_list_roster(list_name)
        {
          addresses: response.parsed_response['people']
        }
      end
    end

    def get_list_roster(list_name)
      request('getListRoster', {
        body: {
          localpart: list_name
        }
      })
    end

    def mock_json
      '{"people": ["rtmeyer@berkeley.edu", "raydavis@berkeley.edu"], "tg_flash": null}'
    end

  end
end
