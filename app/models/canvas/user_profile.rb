module Canvas
  class UserProfile < Proxy
    include SafeJsonParser
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
      @canvas_user_id = options[:canvas_user_id]
    end

    def user_profile
      self.class.fetch_from_cache(@canvas_user_id.to_s) { request_user_profile }
    end

    def get
      profile_response = user_profile
      return profile_response ? safe_json(profile_response.body) : nil
    end

    def existence_check
      true
    end

    private

    def request_user_profile
      request_uncached("users/#{@canvas_user_id}/profile", "_user_profile")
    end

  end
end
