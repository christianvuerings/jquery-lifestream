class GoogleUpdateTaskProxy < GoogleProxy

  def update_task(task_list_id, task_id, body)
    parsed_body = stringify_body(body)
    request(:api => "tasks", :resource => "tasks", :method => "update",
            :params => {tasklist: task_list_id, task: task_id},
            :body => parsed_body, :headers => {"Content-Type" => "application/json"}, :vcr_id => "_tasks")[0]
  end

end
