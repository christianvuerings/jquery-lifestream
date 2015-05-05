module CampusSolutions
  class Proxy < BaseProxy

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::MockableXml

    APP_ID = 'campussolutions'
    APP_NAME = 'Campus Solutions'

    def xml_filename
      ''
    end

    def mock_xml
      read_file('fixtures', 'xml', xml_filename)
    end

    def get
      internal_response = self.class.smart_fetch_from_cache(id: @uid) do
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
      url = @settings.base_url
      logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      request_options = {
        query: {
          'SCC_PROFILE_ID' => @uid,
          'languageCd' => 'ENG'
        }
      }
      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      feed = build_feed response
      if feed.blank?
        feed = response.parsed_response
      end
      {
        statusCode: response.code,
        feed: feed
      }
    end

    def build_feed(response)
      response.parsed_response
    end

  end
end

