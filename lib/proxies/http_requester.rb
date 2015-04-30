module HttpRequester
  def verify_ssl?
    Settings.application.layer == 'production'
  end

  # HTTParty is our preferred HTTP connectivity lib. Use this get_response method wherever possible.
  def get_response(url, additional_options={})
    ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
      error_options = additional_options.delete(:on_error) || {}
      error_options.merge!(url: url)
      request_type = additional_options.delete(:method) || :get
      request_options = {
        timeout: Settings.application.outgoing_http_timeout,
        verify: verify_ssl?
      }.merge(additional_options)
      response = case request_type
        when :delete
          HTTParty.delete(url, request_options)
        when :get
          HTTParty.get(url, request_options)
        when :post
          HTTParty.post(url, request_options)
        else
          raise Errors::ProxyError.new("Unhandled request type #{request_type}", error_options)
      end
      begin
        if error_options[:rescue_status] == response.code || error_options[:rescue_status] == :all
          return response
        end

        if response.code >= 400
          error_options.merge!(response: response)
          error_options.merge!(uid: @uid) if @uid
          raise Errors::ProxyError.new('Connection failed', error_options)
        end
        if response.parsed_response.nil?
          logger.error "Unable to parse response from URL (#{url}), remote server status: #{response.code}, body: #{response.body}"
        end
      rescue MultiXml::ParseError => e
        raise Errors::ProxyError.new("Error parsing XML: #{e.message}", error_options.merge!(response: response))
      rescue JSON::ParserError => e
        raise Errors::ProxyError.new("Error parsing JSON: #{e.message}", error_options.merge!(response: response))
      end
      response
    end
  rescue Timeout::Error
    raise Errors::ProxyError.new('Timeout error', url: url)
  end

end
