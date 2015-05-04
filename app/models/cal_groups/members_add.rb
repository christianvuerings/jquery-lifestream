module CalGroups
  class MembersAdd < Members

    def add(uids)
      handling_exceptions(request_path) do
        response = request({
          #A 500 response may indicate partial success.
          on_error: {rescue_status: 500},
          method: :put,
          headers: {'Content-Type' => 'text/x-json; charset=UTF-8'},
          body: {
            WsRestAddMemberRequest: {
              replaceAllExisting: 'F',
              subjectLookups: uids.map { |uid| {subjectId: uid} }
            }
          }.to_json
        })
        if response['WsAddMemberResults'] && response['WsAddMemberResults']['results']
          {
            group: parse_group(response['WsAddMemberResults']['wsGroupAssigned']),
            members: parse_members(response['WsAddMemberResults']['results'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_members_add.json')
    end

    def mock_request
      super.merge(method: :put)
    end

    def mock_response
      super.merge(status: 500)
    end

    def parse_members(results)
      results.map do |result|
        parse_member(result['wsSubject']).merge({
          added: (result['resultMetadata']['resultCode'] == 'SUCCESS'),
        })
      end
    end

  end
end
