module GoogleApps
  class Revoke < Proxy

    include ClassLogger

    def revoke
      # Google::APIClient does not implement the token revocation endpoint, so we get it via a regular HTTParty request.
      response = get_response(
        'https://accounts.google.com/o/oauth2/revoke',
        query: {token: @authorization.access_token})
      if response.code == 200
        logger.warn "Successfully revoked Google access token for user #{@uid}"
        true
      else
        logger.error "Got an error trying to revoke Google access token for user #{@uid}. Status: #{response.code} Body: #{response.body}"
        false
      end
    end

  end
end

