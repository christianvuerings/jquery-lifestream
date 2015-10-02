module GoogleApps
  class CredentialStore
    include ClassLogger

    def initialize(uid, options = {})
      @uid = uid
      raise ArgumentError, 'UID is blank' if @uid.blank?
      @options = options.symbolize_keys
    end

    def load_credentials
      credentials = load_credentials_from_db
      if credentials.nil? && @options.has_key?(:access_token) && @options.has_key?(:refresh_token)
        logger.warn "Writing Google auth tokens to database using values found in options hash. UID: #{@uid}"
        write_credentials @options
        credentials = load_credentials_from_db
      end
      logger.error "No Google OAuth tokens found where UID=#{@uid}" if credentials.nil?
      credentials
    end

    ##
    # Write the credentials to database.
    #
    # @param [Signet::OAuth2::Client] auth
    def write_credentials(auth = nil)
      credentials = nil
      if auth
        if auth.is_a?(Hash) && auth.has_key?(:access_token) && auth.has_key?(:refresh_token)
          logger.debug "OAuth tokens in hash, where UID=#{@uid}"
          credentials = update_tokens(auth[:access_token], auth[:refresh_token], auth[:issued_at], auth[:expires_in], @options)
        elsif auth.is_a?(Signet::OAuth2::Client) && auth.access_token && auth.refresh_token
          logger.debug "OAuth tokens in OAuth2 instance, where UID=#{@uid}"
          credentials = update_tokens(auth.access_token, auth.refresh_token, auth.issued_at, auth.expires_in, @options)
        end
      end
      logger.warn "Google OAuth tokens not found during attempted database update. UID=#{@uid}; auth.class #{auth.class}" if credentials.nil?
      credentials
    end

    private

    def update_tokens(access_token, refresh_token, issued_at, expires_in, options = {})
      tokens_missing = access_token.blank? || refresh_token.blank?
      raise ArgumentError, "Google 'access_token' and/or 'refresh_token' are blank where UID=#{@uid}" if tokens_missing
      expiration_time = issued_at.blank? || expires_in.blank? ? 0 : issued_at.to_i + expires_in.to_i
      logger.debug "Put OAuth tokens to db where UID=#{@uid}"
      User::Oauth2Data.new_or_update(@uid.to_s, GoogleApps::Proxy::APP_ID, access_token, refresh_token,
                                     expiration_time, options)
    end

    def load_credentials_from_db
      client_id = @options[:client_id] || Settings.google_proxy.client_id
      client_secret = @options[:client_secret] || Settings.google_proxy.client_secret
      scope = @options[:scope] || Settings.google_proxy.scope
      raise ArgumentError "Incomplete Google credential configuration where client_id=#{client_id}" if client_id.blank? || client_secret.blank? || scope.blank?
      oauth2_data = User::Oauth2Data.get(@uid, GoogleApps::Proxy::APP_ID)
      credentials = nil
      if !oauth2_data.nil? && oauth2_data.any?
        credentials = { :client_id => client_id, :client_secret => client_secret, :scope => scope }
        credentials.merge! oauth2_data.symbolize_keys
        # Infer properties wanted by Google
        unless credentials[:expires_in] && credentials[:issued_at]
          credentials[:expires_in] = 3600
          expiration_time = credentials[:expiration_time].to_i
          credentials[:issued_at] = Time.at(expiration_time - 3600)
        end
        credentials[:token_credential_uri] = 'https://accounts.google.com/o/oauth2/token'
      end
      credentials
    end

  end
end
