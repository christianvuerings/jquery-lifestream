module CalGroups
  class MembersCheck < Members

    def check(uids)
      handling_exceptions(request_path) do
        response = request({
          method: :post,
          headers: {'Content-Type' => 'text/x-json; charset=UTF-8'},
          body: {
            WsRestHasMemberRequest: {
              subjectLookups: uids.map { |uid| {subjectId: uid} }
            }
          }.to_json
        })
        if successful?(response)
          {
            group: parse_group(response['WsHasMemberResults']['wsGroup']),
            members: parse_members(response['WsHasMemberResults']['results'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_members_check.json')
    end

    def mock_request
      super.merge(method: :post)
    end

    def parse_members(results)
      results.map do |result|
        parse_member(result['wsSubject']).merge({
          isMember: (result['resultMetadata']['resultCode'] == 'IS_MEMBER')
        })
      end
    end

  end
end
