module GoogleApps
  class TasksList < Tasks

    def initialize(options = {})
      super options
      @json_filename='google_tasks_list.json'
    end

    def mock_request
      super.merge(method: :get,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/@default/tasks')
    end

    def tasks_list(optional_params={})
      optional_params.reverse_merge!(:tasklist => '@default', :maxResults => 100)
      request :api => "tasks", :resource => "tasks", :method => "list", :params => optional_params,
              :page_limiter => 2

    end

  end
end
