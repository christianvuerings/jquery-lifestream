module GoogleApps
  class CreateTaskList < Tasks

    def create_task_list(body)
      parsed_body = stringify_body(body)
      request(:api => "tasks", :resource => "tasklists", :method => "insert",
              :body => parsed_body, :headers => {"Content-Type" => "application/json"}, :vcr_id => "_tasks").first
    end

  end
end
