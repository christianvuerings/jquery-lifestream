module CalGroups
  class MemberAdd < Member

    def add
      handling_exceptions(request_path) do
        response = request({
          method: :put
        })
        if successful?(response)
          {
            added: (result_code(response) == 'SUCCESS'),
            group: parse_group(response['WsAddMemberLiteResult']['wsGroupAssigned']),
            member: parse_member(response['WsAddMemberLiteResult']['wsSubject'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_member_add.json')
    end

    def mock_request
      super.merge(method: :put)
    end

  end
end
