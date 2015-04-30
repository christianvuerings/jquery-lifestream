module Calmail
  class DomainMailingLists < Proxy
    include ClassLogger
    include ResponseWrapper

    def get_list_names
      handling_exceptions(@settings.domain) do
        list_names = []
        response_hash = request('getDomainLists').parsed_response
        response_hash.each do |address, description|
          if (list_name = /([^@]+)@#{@settings.domain}/.match(address))
            list_names << list_name[1]
          end
        end
        {lists: list_names}
      end
    end

    def mock_json
      '{"test-mailing-list@bcourses-lists.berkeley.edu": "", "tg_flash": null, "raytest@bcourses-lists.berkeley.edu": "Test mailing list for bCourses development"}'
    end

  end
end
