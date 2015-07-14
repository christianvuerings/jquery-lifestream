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

    def login_id
      profile = get
      return profile if profile.nil?
      profile['login_id']
    end

    def existence_check
      true
    end

    private

    def request_user_profile
      request_uncached request_path
    end

    def request_path
      "users/#{@canvas_user_id}/profile"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_user_profile.json')
    end

  end
end
