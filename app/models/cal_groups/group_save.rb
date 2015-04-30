module CalGroups
  class GroupSave < Group

    def save
      qualified_name = qualify @group_name
      handling_exceptions(qualified_name) do
        response = request({
          body: {
            wsLiteObjectType: 'WsRestGroupSaveLiteRequest',
            groupName: qualified_name,
            saveMode: 'INSERT'
          },
          method: :post,
          on_error: {rescue_status: 500}
        })
        if successful?(response) && response.code == 201
          {
            created: true,
            group: response['WsGroupSaveLiteResult']['wsGroup']
          }
        elsif response.code == 500 && result_code(response) == 'GROUP_ALREADY_EXISTS'
          {
            created: false,
            group: response['WsGroupSaveLiteResult']['wsGroup']
          }
        else
          raise Errors::ProxyError.new('Error response from CalGroups', {response: response})
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_groups_group_save_success.json')
    end

    def mock_request
      super.merge(method: :post)
    end

    def mock_response
      super.merge(status: 201)
    end

  end
end
