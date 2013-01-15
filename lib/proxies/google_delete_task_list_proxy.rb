class GoogleDeleteTaskListProxy < GoogleTasksProxy

  def delete_task_list(task_list_id)
    response = request(:api => "tasks", :resource => "tasklists", :method => "delete",
                       :params => {tasklist: task_list_id}, :vcr_id => "_tasks")[0]
    #According to the API, empty response body == successful
    response.data.blank?
  end

end
