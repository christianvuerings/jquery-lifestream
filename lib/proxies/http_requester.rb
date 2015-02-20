module HttpRequester
  def verify_ssl?
    Settings.application.layer == 'production'
  end

  # HTTParty is our preferred HTTP connectivity lib. Use this get_response method wherever possible.
  def get_response(url, additional_options={})
    ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
      error_options = additional_options.delete(:on_error) || {}
      response = HTTParty.get(
        url,
        {
          timeout: Settings.application.outgoing_http_timeout,
          verify: verify_ssl?
        }.merge(additional_options)
      )
      begin
        if error_options[:rescue_status] == response.code || error_options[:rescue_status] == :all
          return response
        end

        if response.code >= 400
          error_options.merge!(url: url, response: response)
          error_options.merge!(uid: @uid) if @uid
          raise Errors::ProxyError.new('Connection failed', error_options)
        end
        if response.parsed_response.nil?
          logger.error "Unable to parse response from URL (#{url}), remote server status: #{response.code}, body: #{response.body}"
        end
      rescue MultiXml::ParseError => e
        raise Errors::ProxyError.new("Error parsing XML: #{e.message}", url: url, response: response)
      rescue JSON::ParserError => e
        raise Errors::ProxyError.new("Error parsing JSON: #{e.message}", url: url, response: response)
      end
      response
    end
  rescue Timeout::Error
    raise Errors::ProxyError.new('Timeout error', url: url)
  end

end
