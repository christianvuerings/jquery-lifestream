module GoogleApps
  class ClearTaskList < Tasks

    def mock_request
      super.merge(method: :post,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/@default/clear')
    end

    def mock_response
      super.merge({status: 204})
    end

    def mock_json
      '{}'
    end

    def clear_task_list(task_list_id)
      proxy_response = request(:api => "tasks", :resource => "tasks", :method => "clear",
                               :params => {tasklist: task_list_id}).first
      #According to the API, empty response body == successful
      response_state = proxy_response && proxy_response.data.blank? && proxy_response.response.status == 204
      response_state ||= false
      if !response_state
        Rails.logger.warn "#{self.class.name} failed to clear tasklist: #{proxy_response}"
      end
      response_state
    end

  end
end
