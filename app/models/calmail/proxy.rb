module Calmail
  class Proxy < BaseProxy
    include Proxies::Mockable

    # The CalMail API returns content_type of 'text/javascript', which HTTParty parses as plain text by default.
    class LegacyJsonParser < HTTParty::Parser
      SupportedFormats.merge!('text/javascript' => :json)
    end

    def initialize(options = {})
      super(Settings.calmail_proxy, options)
      initialize_mocks if @fake
    end

    def request(path, options = {})
      url = "#{@settings.base_url}/#{path}"
      logger.info "Fake = #{@fake}; Making request to #{url}"

      body_options = options.delete(:body) || {}
      body_options.reverse_merge!(
        apikey: @settings.api_key,
        domain: @settings.domain
      )
      request_options = {
        # For the moment, these requests set an explicit user-agent as a workaround for CLC-5346.
        headers: {'User-Agent' => 'Ruby'},
        method: :post,
        body: body_options,
        parser: LegacyJsonParser
      }.merge(options)

      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      response
    end

    def mock_request
      super.merge(method: :post)
    end

  end
end
