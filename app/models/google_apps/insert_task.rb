module GoogleApps
  class InsertTask < Tasks

    def insert_task(task_list_id, body)
      parsed_body = stringify_body(body)
      request(:api => "tasks", :resource => "tasks", :method => "insert", :params => {tasklist: task_list_id},
              :body => parsed_body, :headers => {"Content-Type" => "application/json"}, :vcr_id => "_tasks").first
    end

  end
end
