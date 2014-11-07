module Canvas
  class AuthorizationConfigs < Proxy
    include SafeJsonParser

    # Unlike other Canvas proxies, this needs to support requests to multiple Canvas servers.
    def initialize(options = {})
      super(options)
      if (canvas_url_root = options[:url_root])
        @settings.url_root = canvas_url_root
      end
    end

    # Do not cache, since this is used to change authentication configurations on multiple Canvas servers.
    # proxy = Canvas::AuthorizationConfigs.new(:url_root => 'https://ucberkeley.beta.instructure.com')
    def authorization_configs
      all_configs = []
      # This API request does not return the 'Link' header enabling pagination
      response = request_uncached(
        "accounts/#{settings.account_id}/account_authorization_configs",
        "_account_authorization_configs"
      )
      if response && response.status == 200 && list = safe_json(response.body)
        all_configs.concat(list)
      end
      all_configs
    end

    # Update
    def reset_authorization_config(config_id, config_hash)
      params = config_hash.to_query
      canvas_url = "accounts/#{settings.account_id}/account_authorization_configs/#{config_id}?#{params}"
      response = request_uncached(canvas_url, '_reset_authorization_config', {
        method: :put
      })
      return safe_json(response.body) if response && response.status == 200
      false
    end

  end
end
