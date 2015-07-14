module Canvas
  class Groups < Proxy

    include Cache::UserCacheExpiry

    def groups
      self.class.fetch_from_cache(@uid) do
        all_groups = []
        params = "as_user_id=sis_login_id:#{@uid}&per_page=100"
        while params do
          response = request_uncached "#{request_path}?#{params}"
          break unless (response && response.status == 200 && groups = safe_json(response.body))
          all_groups.concat(groups)
          params = next_page_params(response)
        end
        all_groups
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
