module CalGroups
  class MemberGet < Member

    def get
      handling_exceptions(request_path) do
        response = request
        if successful?(response)
          {
            isMember: (result_code(response) == 'IS_MEMBER'),
            group: response['WsHasMemberLiteResult']['wsGroup'],
            member: response['WsHasMemberLiteResult']['wsSubject']
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_member_get.json')
    end

  end
end
