module Webcast
  class SystemStatus < Proxy

    def get_json_path
      'warehouse/webcast-system-status.json'
    end

    def request_internal
      {
        :isSignUpActive => Settings.features.videos ? get_json_data['isSignUpActive'] : false
      }
    end

  end
end
