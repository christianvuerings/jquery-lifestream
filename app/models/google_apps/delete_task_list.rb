module GoogleApps
  class DeleteTaskList < Tasks

    def delete_task_list(task_list_id)
      response = request(:api => "tasks", :resource => "tasklists", :method => "delete",
                         :params => {tasklist: task_list_id}).first
      #According to the API, empty response body == successful
      !response.nil? && response.data.blank?
    end

  end
end
