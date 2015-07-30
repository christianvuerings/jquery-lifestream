module Canvas
  class SisUserProfile < Proxy
    include SafeJsonParser

    def get
      sis_user_profile[:body] if sis_user_profile[:statusCode] < 400
    end

    def sis_user_profile
      self.class.fetch_from_cache(@uid) { wrapped_get request_path }
    end

    def existence_check
      true
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_sis_user_profile.json')
    end

    def request_path
      "users/sis_login_id:#{@uid}/profile"
    end
  end
end
