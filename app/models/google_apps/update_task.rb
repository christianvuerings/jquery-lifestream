module GoogleApps
  class UpdateTask < Tasks

    def update_task(task_list_id, task_id, body)
      parsed_body = stringify_body(body)
      request(:api => "tasks", :resource => "tasks", :method => "update",
              :params => {tasklist: task_list_id, task: task_id},
              :body => parsed_body, :headers => {"Content-Type" => "application/json"}, :vcr_id => "_tasks").first
    end

  end
end
