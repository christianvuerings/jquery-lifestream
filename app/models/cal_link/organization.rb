module CalLink
  class Organization < Proxy

    include SafeJsonParser
    include Cache::UserCacheExpiry

    def initialize(options = {})
      @org_id = options[:org_id].to_s
      super(options)
    end

    def get_organization
      self.class.smart_fetch_from_cache(id: @org_id, user_message_on_exception: 'Remote server unreachable') do
        request_internal
      end
    end

    private

    def mock_request
      super.merge(uri_matching: request_url, query_including: request_params)
    end

    def mock_response
      response_bodies = safe_json(read_file('fixtures', 'json', 'cal_link_organizations.json'))
      if (response_body = response_bodies.find{ |body| body['items'].first['organizationId'] ==  @org_id.to_i})
        {
          status: 200,
          headers: {'Content-Type' => 'application/json'},
          body: response_body.to_json
        }
      else
        {
          status: 404
        }
      end
    end

    def request_internal
      params = request_params.merge common_cal_link_params
      logger.info "Fake = #{@fake}; Making request to #{request_url}; params = #{params}, cache expiration #{self.class.expires_in}"

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
      {organizationId: @org_id}
    end

    def request_url
      "#{@settings.base_url}/api/organizations"
    end

  end
end
