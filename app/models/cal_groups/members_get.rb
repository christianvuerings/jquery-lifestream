module CalGroups
  class MembersGet < Members

    def initialize(options = {})
      @group_name = options[:group_name]
      super(options)
    end

    def get
      handling_exceptions(qualify @group_name) do
        response = request
        if successful?(response)
          {
            group: parse_group(response['WsGetMembersLiteResult']['wsGroup']),
            members: parse_members(response['WsGetMembersLiteResult']['wsSubjects'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_members_get.json')
    end

    def parse_members(members)
      return [] unless members
      members.map do |member|
        {
          id: member['id']
        }
      end
    end

  end
end
