module Canvas
  class UserProfile < Proxy
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
      @canvas_user_id = options[:canvas_user_id]
    end

    def get
      user_profile[:body] if user_profile[:statusCode] < 400
    end

    def login_id
      user_profile[:body]['login_id'] if user_profile[:statusCode] < 400
    end

    def user_profile
      self.class.fetch_from_cache(@canvas_user_id.to_s) { wrapped_get request_path }
    end

    def existence_check
      true
    end

    private

    def request_path
      "users/#{@canvas_user_id}/profile"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_user_profile.json')
    end

  end
end
