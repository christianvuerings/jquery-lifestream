module Canvas
  class AuthorizationConfigs < Proxy

    # Do not cache, since this is used to change authentication configurations on multiple Canvas servers.
    # proxy = Canvas::AuthorizationConfigs.new(:url_root => 'https://ucberkeley.beta.instructure.com')
    def authorization_configs
      paged_get request_path
    end

    # Update
    def reset_authorization_config(config_id, config_hash)
      wrapped_put "#{request_path}/#{config_id}?#{config_hash.to_query}"
    end

    private

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', 'canvas_account_authorization_configs.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :put)
        .respond_with_file('fixtures', 'json', 'canvas_reset_authorization_config.json')
    end

    def request_path
      "accounts/#{settings.account_id}/authentication_providers"
    end

  end
end
