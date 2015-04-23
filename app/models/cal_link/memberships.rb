module CalLink
  class Memberships < Proxy
    include Cache::UserCacheExpiry

    def get_memberships
      self.class.smart_fetch_from_cache(id: @uid, user_message_on_exception: 'Remote server unreachable') do
        request_internal
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'cal_link_memberships.json')
    end

    def mock_request
      super.merge(uri_matching: request_url)
    end

    def request_internal
      params = request_params.merge common_cal_link_params
      logger.info "Fake = #{@fake}; Making request to #{request_url} on behalf of user #{@uid}; params = #{params}, cache expiration #{self.class.expires_in}"

      response = ActiveSupport::Notifications.instrument('proxy', { url: request_url, class: self.class }) do
        get_response(request_url, {query: params})
      end
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"

      {
        body: response.parsed_response,
        statusCode: response.code
      }
    end

    def request_params
      {
        username: @uid,
        currentMembershipsOnly: true
      }
    end

    def request_url
      "#{@settings.base_url}/api/memberships"
    end

  end
end
