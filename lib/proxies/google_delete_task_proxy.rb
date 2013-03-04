class GoogleDeleteTaskProxy < GoogleTasksProxy

  def delete_task(task_list_id, task_id)
    proxy_response = request(:api => "tasks", :resource => "tasks", :method => "delete",
                       :params => {tasklist: task_list_id, task: task_id}, :vcr_id => "_tasks_delete")[0]
    response_state = proxy_response.data.blank? && proxy_response.response.status == 204
    if !response_state
      Rails.logger.warn "#{self.class.name} failed to clear tasklist: #{proxy_response}"
    end
    response_state
  end

end
