module CalGroups
  class GetMembers < Proxy
    include ClassLogger
    include ResponseWrapper

    def initialize(options = {})
      @group_name = options[:group_name]
      super(options)
    end

    def get_members
      handling_exceptions(qualify @group_name) do
        response = request
        if response['WsGetMembersLiteResult']
          {
            members: (response['WsGetMembersLiteResult']['wsSubjects'] || [])
          }
        else
          raise Errors::ProxyError.new('Could not parse results from CalGroups', {response: response})
        end
      end
    end

    private

    def request_path
      "groups/#{URI.escape(qualify @group_name)}/members"
    end

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_get_members.json')
    end

  end
end
