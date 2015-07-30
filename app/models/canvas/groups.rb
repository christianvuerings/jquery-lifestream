module Canvas
  class Groups < Proxy

    include Cache::UserCacheExpiry

    def groups
      self.class.fetch_from_cache(@uid) do
        paged_get request_path, as_user_id: "sis_login_id:#{@uid}"
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_groups.json')
    end

    def request_path
      'users/self/groups'
    end
  end
end
