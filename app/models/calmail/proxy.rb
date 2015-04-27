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
      body_options = options.delete(:body) || {}
      body_options.reverse_merge!(
        apikey: @settings.api_key,
        domain: @settings.domain
      )
      request_options = {
        method: :post,
        body: body_options,
        parser: LegacyJsonParser
      }.merge(options)
      get_response(url, request_options)
    end

    def mock_request
      super.merge(method: :post)
    end

  end
end
