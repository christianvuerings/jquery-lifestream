module GoogleApps
  class ClearTaskList < Tasks

    def clear_task_list(task_list_id)
      proxy_response = request(:api => "tasks", :resource => "tasks", :method => "clear",
                               :params => {tasklist: task_list_id}, :vcr_id => "_tasks_clear").first
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
