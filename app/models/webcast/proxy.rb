module Webcast
  class Proxy < BaseProxy

    include ClassLogger, SafeJsonParser

    PROXY_ERROR = {
      :proxy_error_message => 'There was a problem fetching the Webcast-related data'
    }

    def initialize(options = {})
      super(Settings.webcast_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache(
        {user_message_on_exception: PROXY_ERROR[:proxy_error_message]}) do
        request_internal
      end
    end

    def get_json_data
      json_url = "#{@settings.base_url}/#{get_json_path}"
      if @fake
        path = Rails.root.join('fixtures', 'webcast', get_json_path).to_s
        logger.info "Fake = #{@fake}. Get JSON from fixture file #{path}. Cache expires in: #{self.class.expires_in}"
        json_data = safe_json File.read(path)
      else
        response = get_response(
          json_url,
          basic_auth: {username: @settings.username, password: @settings.password},
          on_error: {return_feed: PROXY_ERROR}
        )
        json_data = response.parsed_response
      end

      if json_data && (json_data.is_a? Hash)
        json_data
      else
        raise Errors::ProxyError.new(
                'Error occurred converting response to json',
                response: response,
                url: json_url,
                return_feed: PROXY_ERROR)
      end
    end

    def get_json_path
      # subclasses override
    end

  end
end
