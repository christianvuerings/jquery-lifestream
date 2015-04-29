module GoogleApps
  class DeleteTask < Tasks

    def mock_request
      super.merge(method: :delete,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA/tasks/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjEzODE3NzMzNzg')
    end

    def mock_response
      super.merge({status: 204})
    end

    def mock_json
      '{}'
    end

    def delete_task(task_list_id, task_id)
      proxy_response = request(:api => "tasks", :resource => "tasks", :method => "delete",
                               :params => {tasklist: task_list_id, task: task_id}).first
      response_state = proxy_response && proxy_response.data.blank? && proxy_response.response.status == 204
      response_state ||= false
      if !response_state
        Rails.logger.warn "#{self.class.name} failed to clear tasklist: #{proxy_response}"
      end
      response_state
    end

  end
end
