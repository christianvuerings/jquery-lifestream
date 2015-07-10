module Canvas
  class SisUserProfile < Proxy
    include SafeJsonParser

    def sis_user_profile
      request request_path
    end

    def get
      profile_response = sis_user_profile
      return profile_response ? safe_json(profile_response.body) : nil
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
