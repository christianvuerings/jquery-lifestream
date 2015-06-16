module Proxies
  module HttpClient

    # This method wraps HTTParty, our preferred HTTP connectivity lib. Use it wherever possible.
    def get_response(url, options={})
      ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
        error_options = options.delete(:on_error) || {}

        request_type = options.delete(:method) || :get
        unless (request = HttpRequest.request_with_method request_type)
          raise Errors::ProxyError.new("Unhandled request type #{request_type}", error_options)
        end

        error_options[:uid] = @uid if @uid
        error_options[:url] = url
        request.perform(url, options, error_options)
      end
    end

  end
end
