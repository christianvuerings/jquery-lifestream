module Webcast
  class SystemStatus < Proxy

    def initialize(options = {})
      super(options)
    end

    def get_json_path
      'webcast-system-status.json'
    end

    def request_internal
      return {} unless Settings.features.videos
      is_active_value = get_json_data['isSignUpActive']
      is_sign_up_active = is_active_value && is_active_value.strip.casecmp('true') == 0
      { 'is_sign_up_active' => is_sign_up_active }
    end

  end
end
