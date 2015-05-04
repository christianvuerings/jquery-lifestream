module CalGroups
  class MemberCheck < Member

    def check
      handling_exceptions(request_path) do
        response = request
        if successful?(response)
          {
            isMember: (result_code(response) == 'IS_MEMBER'),
            group: parse_group(response['WsHasMemberLiteResult']['wsGroup']),
            member: parse_member(response['WsHasMemberLiteResult']['wsSubject'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_member_check.json')
    end

  end
end
