module CalGroups
  class MembersDelete < Members

    def delete(uids)
      handling_exceptions(request_path) do
        response = request({
          method: :post,
          headers: {'Content-Type' => 'text/x-json; charset=UTF-8'},
          body: {
            WsRestDeleteMemberRequest: {
              subjectLookups: uids.map { |uid| {subjectId: uid} }
            }
          }.to_json
        })
        if successful?(response)
          {
            group: parse_group(response['WsDeleteMemberResults']['wsGroup']),
            members: parse_members(response['WsDeleteMemberResults']['results'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_members_delete.json')
    end

    def mock_request
      super.merge(method: :post)
    end

    def parse_members(results)
      results.map do |result|
        parse_member(result['wsSubject']).merge({
          deleted: (result['resultMetadata']['resultCode'] == 'SUCCESS'),
        })
      end
    end

  end
end
