module GoogleApps
  class CredentialStore < Google::APIClient::FileStore

    def initialize(app_name = nil)
      super File.join(Rails.root, 'tmp/google', "#{app_name || 'default'}-credentials.json")
      @app_name = app_name
    end

    def load_credentials
      google_configs = Settings.google_proxy.marshal_dump
      if @app_name.nil?
        # Use default client credentials
        credentials = google_configs
      else
        # Custom clients can be configured via YAML convention: google_proxy.my_app.client_id, etc.
        key = @app_name.to_sym
        credentials = google_configs[key].marshal_dump if google_configs.has_key? key
      end
      # Per Google API spec
      credentials[:token_credential_uri] = 'https://accounts.google.com/o/oauth2/token' unless credentials.nil?
      credentials
    end

  end
end
