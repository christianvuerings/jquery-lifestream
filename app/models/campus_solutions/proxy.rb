module CampusSolutions
  class Proxy < BaseProxy

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::MockableXml
    include User::Student

    APP_ID = 'campussolutions'
    APP_NAME = 'Campus Solutions'

    def instance_key
      @uid
    end

    def xml_filename
      ''
    end

    def mock_xml
      read_file('fixtures', 'xml', 'campus_solutions', xml_filename)
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
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, campus_solutions_id = #{@campus_solutions_id}; cache expiration #{self.class.expires_in}"
        logger.debug "Request options = #{request_options}"
        response = get_response(url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body.force_encoding('UTF-8')}"
        feed = build_feed response
        feed = convert_feed_keys(feed)
        if is_errored?(feed)
          {
            statusCode: 400,
            errored: true,
            feed: feed
          }
        else
          {
            statusCode: response.code,
            feed: feed
          }
        end
      end
    end

    def convert_feed_keys(feed)
      HashConverter.downcase_and_camelize(feed)
    end

    def url
      @settings.base_url
    end

    def is_errored?(feed)
      feed[:errmsgtext].present?
    end

    def request_options
      {}
    end

    def build_feed(response)
      response.parsed_response
    end

    def is_feature_enabled
      true
    end

  end
end

