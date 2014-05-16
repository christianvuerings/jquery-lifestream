module Canvas
  class SisUserProfile < Proxy
    include SafeJsonParser

    def sis_user_profile
      request("users/sis_login_id:#{@uid}/profile", "_sis_user_profile")
    end

    def get
      profile_response = sis_user_profile
      return profile_response ? safe_json(profile_response.body) : nil
    end

    def existence_check
      true
    end

  end
end
