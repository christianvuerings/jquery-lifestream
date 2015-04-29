module GoogleApps
  class CreateTaskList < Tasks

    def initialize(options = {})
      super options
      @json_filename='google_create_task_list.json'
    end

    def mock_request
      super.merge(method: :post,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/users/@me/lists')
    end

    def create_task_list(body)
      parsed_body = stringify_body(body)
      request(:api => "tasks", :resource => "tasklists", :method => "insert",
              :body => parsed_body, :headers => {"Content-Type" => "application/json"}).first
    end

  end
end
