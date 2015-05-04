module CalGroups
  class MemberDelete < Member

    def delete
      handling_exceptions(request_path) do
        response = request(method: :delete)
        if successful?(response)
          {
            deleted: (result_code(response) == 'SUCCESS'),
            group: parse_group(response['WsDeleteMemberLiteResult']['wsGroup']),
            member: parse_member(response['WsDeleteMemberLiteResult']['wsSubject'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_member_delete.json')
    end

    def mock_request
      super.merge(method: :delete)
    end

  end
end
