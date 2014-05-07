module Canvas
  class UserProfile < Proxy
    include SafeJsonParser, Cache::UserCacheExpiry

    def user_profile
      request("users/sis_login_id:#{@uid}/profile", "_user_profile")
    end

    def get
      profile_response = user_profile
      return profile_response ? safe_json(profile_response.body) : nil
    end

    def existence_check
      true
    end

  end
end
