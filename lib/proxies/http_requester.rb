module HttpRequester
  def verify_ssl?
    Settings.application.layer == 'production'
  end

  # HTTParty is our preferred HTTP connectivity lib. Use this get_response method wherever possible.
  def get_response(url, additional_options={})
    ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
      response = HTTParty.get(
        url,
        {
          timeout: Settings.application.outgoing_http_timeout,
          verify: verify_ssl?
        }.merge(additional_options)
      )
      begin
        if response.parsed_response.nil?
          logger.error "Unable to parse response from URL (#{url}), remote server status: #{response.code}, body: #{response.body}"
        end
      rescue MultiXml::ParseError => e
        raise Errors::ProxyError.new("Error parsing XML from URL (#{url}): #{e.message}, remote server status #{response.code}, body: #{response.body}", nil)
      rescue JSON::ParserError => e
        raise Errors::ProxyError.new("Error parsing JSON from URL (#{url}): #{e.message}, remote server status #{response.code}, body: #{response.body}", nil)
      end
      response
    end
  end

end
