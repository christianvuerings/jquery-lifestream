module CalGroups
  class GroupDelete < Group

    def delete
      handling_exceptions(qualify @group_name) do
        response = request(method: :delete)
        if successful?(response) && response['WsGroupDeleteLiteResult']
          {
            deleted: (result_code(response) == 'SUCCESS'),
            group: parse_group(response['WsGroupDeleteLiteResult']['wsGroup'])
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_group_delete.json')
    end

    def mock_request
      super.merge(method: :delete)
    end

  end
end
