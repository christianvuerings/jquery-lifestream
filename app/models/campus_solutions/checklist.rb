module CampusSolutions
  class Checklist < BaseProxy

    APP_ID = 'campussolutions'
    APP_NAME = 'Campus Solutions'

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.cs_checklist_proxy, options)
      initialize_mocks if @fake
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

    private

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
      feed = response.parsed_response['SCC_GET_CHKLST_RESP']
      if feed.blank?
        feed = response.parsed_response
      end
      {
        statusCode: response.code,
        feed: feed
      }
    end

    def mock_json
      xml = MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'cs_checklist_feed.xml'))
      xml['SCC_GET_CHKLST_RESP'].to_json
    end

  end
end
