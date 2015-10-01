module CalnetCrosswalk
  class Proxy < BaseProxy

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable
    include Cache::RelatedCacheKeyTracker

    APP_ID = 'calnetcrosswalk'
    APP_NAME = 'Calnet Crosswalk'

    def initialize(options = {})
      super(Settings.calnet_crosswalk_proxy, options)
      initialize_mocks if @fake
    end

    def instance_key
      @uid
    end

    def json_filename
      "calnet_crosswalk_#{@uid}.json"
    end

    def mock_json
      json = read_file('fixtures', 'json', json_filename)
      if json.blank?
        # fall back to an EMPLID that we know is in CS
        json = read_file('fixtures', 'json', 'calnet_crosswalk_12345.json')
      end
      json
    end

    def mock_request
      super.merge(uri_matching: "#{@settings.base_url}/#{@uid}")
    end

    def get
      internal_response = self.class.smart_fetch_from_cache(id: instance_key) do
        get_internal
      end
      if internal_response[:noStudentId] || internal_response[:statusCode] < 400
        internal_response
      else
        {
          errored: true
        }
      end
    end

    def get_internal
      logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      feed = response.parsed_response
      {
        statusCode: response.code,
        feed: feed
      }
    end

    def url
      "#{@settings.base_url}/#{@uid}"
    end

    def request_options
      {
        digest_auth: {username: @settings.username, password: @settings.password}
      }
    end

    def lookup_campus_solutions_id
      self.class.fetch_from_cache("#{@uid}/campus_solutions_id") do
        self.class.save_related_cache_key(@uid, self.class.cache_key("#{@uid}/campus_solutions_id"))
        cs_id = nil
        feed = get[:feed]
        if feed.present?
          feed['Person']['identifiers'].each do |identifier|
            if identifier['identifierTypeName'] == 'CAMPUS_SOLUTIONS_ID'
              cs_id = identifier['identifierValue']
              logger.debug "cs_id is #{cs_id}"
              break
            end
          end
        end
        cs_id
      end
    end

  end
end
