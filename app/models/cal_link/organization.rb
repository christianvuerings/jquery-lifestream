module CalLink
  class Organization < Proxy

    include SafeJsonParser
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
      @org_id = options[:org_id]
    end

    def get_organization
      self.class.smart_fetch_from_cache({id: @org_id, user_message_on_exception: "Remote server unreachable"}) do
        request_internal
      end
    end

    def request_internal
      url = "#{Settings.cal_link_proxy.base_url}/api/organizations"
      params = build_params
      Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url}; params = #{params}, cache expiration #{self.class.expires_in}"

      response = ActiveSupport::Notifications.instrument('proxy', { url: url, class: self.class }) do
        FakeableProxy.wrap_request(APP_ID + "_organization", @fake, {:match_requests_on => [:method, :path, self.method(:custom_query_matcher).to_proc, :body]}) {
          get_response(
            url,
            query: params
          )
        }
      end
      if response.code >= 400
        raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}")
      end
      Rails.logger.debug "#{self.class.name}: Remote server status #{response.code}, Body = #{response.body}"
      {
        :body => safe_json(response.body),
        :statusCode => response.code
      }
    end

    private

    def custom_query_matcher(uri_1, uri_2)
      a_uri = URI(uri_1.uri).query
      b_uri = URI(uri_2.uri).query
      if !a_uri.blank? && !b_uri.blank?
        a_param_hash = CGI::parse(a_uri)
        b_param_hash = CGI::parse(b_uri)
        a_param_hash["organizationId"] == b_param_hash["organizationId"]
      else
        a_uri == b_uri
      end
    end

    def build_params
      params = super
      params.merge(
        {
          :organizationId => @org_id
        })
    end


  end
end
