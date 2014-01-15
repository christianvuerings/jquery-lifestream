class CalLinkMembershipsProxy < CalLinkProxy

  include SafeJsonParser

  def get_memberships
    self.class.fetch_from_cache @uid do
      url = "#{Settings.cal_link_proxy.base_url}/api/memberships"
      params = build_params
      Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; params = #{params}, cache expiration #{self.class.expires_in}"
      begin
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
          Rails.logger.error "#{self.class.name}: Connection failed: #{response.status} #{response.body}"
          return nil
        end
        Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
        {
            :body => safe_json(response.body),
            :status_code => response.status
        }
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError  => e
        Rails.logger.error "#{self.class.name}: Connection failed: #{e.class} #{e.message}"
        {
            :body => "Remote server unreachable",
            :status_code => 503
        }
      end
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
