class CalLinkMembershipsProxy < CalLinkProxy

  include SafeJsonParser

  def get_memberships
    safe_request("Remote server unreachable") do
      internal_get_memberships
    end
  end

  def internal_get_memberships
    self.class.fetch_from_cache @uid do
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
        raise Calcentral::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}")
      end
      Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
      {
        :body => safe_json(response.body),
        :status_code => response.status
      }
    end
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
