module GoogleApps
  class UpdateTask < Tasks

    def initialize(options = {})
      super options
      #@json_filename='google_tasks_update.json'
      @json_filename='google_tasks_update_successful.json'
    end

    def mock_request
      #super.merge(method: :get,
      #            uri_matching: 'https://www.googleapis.com/tasks/v1/users/@me/lists')
      super.merge(method: :put,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA/tasks/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjEzODE3NzMzNzg')
    end

    def update_task(task_list_id, task_id, body)
      parsed_body = stringify_body(body)
      request(:api => "tasks", :resource => "tasks", :method => "update",
              :params => {tasklist: task_list_id, task: task_id},
              :body => parsed_body, :headers => {"Content-Type" => "application/json"}).first
    end

  end
end
