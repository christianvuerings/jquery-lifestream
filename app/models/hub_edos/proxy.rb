module HubEdos
  class Proxy < BaseProxy

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable
    include CampusSolutions::ProfileFeatureFlagged
    include User::Student

    APP_ID = 'integrationhub'
    APP_NAME = 'Integration Hub'

    def instance_key
      @uid
    end

    def json_filename
      ''
    end

    def mock_json
      read_file('fixtures', 'json', json_filename)
    end

    def mock_request
      super.merge(uri_matching: url)
    end

    def get
      if is_feature_enabled
        internal_response = self.class.smart_fetch_from_cache(id: instance_key) do
          get_internal
        end
        if internal_response[:noStudentId] || internal_response[:statusCode] < 400
          internal_response
        else
          internal_response.merge({
                                    errored: true
                                  })
        end
      else
        {}
      end
    end

    def get_internal
      @campus_solutions_id = lookup_campus_solutions_id
      if @campus_solutions_id.nil?
        logger.info "Lookup of campus_solutions_id for uid #{@uid} failed, cannot call Campus Solutions API"
        {
          noStudentId: true
        }
      else
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        response = get_response(url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        feed = response.parsed_response
        {
          statusCode: response.code,
          feed: feed
        }
      end
    end

    def url
      @settings.base_url
    end

    def request_options
      {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        }
      }
    end

  end
end

