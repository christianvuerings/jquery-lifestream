module CalGroups
  class FindGroups < Proxy
    include ClassLogger
    include ResponseWrapper

    def name_available?(name)
      qualified_name = qualify name
      handling_exceptions(qualified_name) do
        find_group_by_name(qualified_name).empty?
      end
    end

    def find_group_by_name(qualified_name)
      response = request({
        body: {
          wsLiteObjectType: 'WsRestFindGroupsLiteRequest',
          queryFilterType: 'FIND_BY_GROUP_NAME_EXACT',
          groupName: qualified_name
        },
        method: :post
      })
      if successful?(response) && response['WsFindGroupsResults']
        if (groups = response['WsFindGroupsResults']['groupResults'])
          groups.map { |group| parse_group group }
        else
          []
        end
      else
        raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_find_groups.json')
    end

    def mock_request
      super.merge(method: :post)
    end

    def request_path
      'groups'
    end

  end
end
