module CampusSolutions
  class Checklist < BaseProxy

    APP_ID = 'campussolutions'
    APP_NAME = 'Campus Solutions'

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable
    include User::Student

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
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Campus Solutions Checklist API"
        {
          noStudentId: true
        }
      else
        url = @settings.base_url
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
        request_options = {
          query: {
            studentId: student_id
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
    end

    def mock_json
      xml = MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'cs_checklist_feed.xml'))
      xml['SCC_GET_CHKLST_RESP'].to_json
    end

  end
end
