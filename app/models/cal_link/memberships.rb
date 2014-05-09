module CalLink
  class Memberships < Proxy

    include SafeJsonParser
    include Cache::UserCacheExpiry

    def get_memberships
      self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: "Remote server unreachable"}) do
        request_internal
      end
    end

    def request_internal
      url = "#{Settings.cal_link_proxy.base_url}/api/memberships"
      params = build_params
      Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; params = #{params}, cache expiration #{self.class.expires_in}"

      response = FakeableProxy.wrap_request(APP_ID + "_memberships", @fake, {:match_requests_on => [:method, :path, :body]}) {
        Faraday::Connection.new(
          :url => url,
          :params => params,
          :request => {
            :timeout => Settings.application.outgoing_http_timeout
          }
        ).get
      }
      if response.status >= 400
        raise Errors::ProxyError.new("Connection failed: #{response.status} #{response.body}; url = #{url}")
      end
      Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
      {
        :body => safe_json(response.body),
        :statusCode => response.status
      }
    end

    private

    def build_params
      params = super
      params.merge(
        {
          :username => @uid,
          :currentMembershipsOnly => true
        })
    end

  end
end
