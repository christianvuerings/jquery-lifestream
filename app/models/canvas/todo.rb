module Canvas
  class Todo < Proxy

    include Cache::UserCacheExpiry

    def todo
      request request_path
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_todo.json')
    end

    def request_path
      "users/self/todo?as_user_id=sis_login_id:#{@uid}"
    end
  end
end
