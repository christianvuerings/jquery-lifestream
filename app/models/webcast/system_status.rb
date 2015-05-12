module Webcast
  class SystemStatus < Proxy

    def get_json_path
      'webcast-system-status.json'
    end

    def request_internal
      {
        'is_sign_up_active' => Settings.features.videos ? get_json_data['isSignUpActive'] : false
      }
    end

  end
end
