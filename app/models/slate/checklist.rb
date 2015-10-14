module Slate
  class Checklist < BaseProxy

    APP_ID = 'slate'
    APP_NAME = 'Slate'

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::MockableXml

    def initialize(options = {})
      super(Settings.slate_checklist_proxy, options)
      initialize_mocks if @fake
    end

    def get
      if Settings.features.slate_checklist
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
      else
        {}
      end
    end

    private

    def get_internal
      url = @settings.base_url
      logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      request_options = {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        },
        query: {
          uid: @uid
        },
        headers: {
          'Accept' => 'text/xml;charset=UTF-8',
          'Accept-Charset' => 'UTF-8'
        }
      }
      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Response encoding = #{response.body.encoding}; Body = #{response.body.force_encoding('UTF-8')}"
      {
        statusCode: response.code,
        feed: response.parsed_response
      }
    end

    def mock_xml
      read_file('fixtures', 'xml', 'slate_checklist_feed.xml')
    end

  end
end
