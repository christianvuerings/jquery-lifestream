module Canvas
  class UpcomingEvents < Proxy

    include Cache::UserCacheExpiry

    def upcoming_events
      request request_path
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_upcoming_events.json')
    end

    def request_path
      "users/self/upcoming_events?as_user_id=sis_login_id:#{@uid}"
    end
  end
end
