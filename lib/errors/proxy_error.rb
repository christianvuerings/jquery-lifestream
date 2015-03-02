module Errors
  class ProxyError < StandardError
    attr_accessor :body, :log_message, :response, :status, :uid, :url, :wrapped_exception

    def initialize(log_message = '', opts={})
      @log_message = log_message
      @url = opts[:url]
      @uid = opts[:uid]

      if (response = opts[:response])
        @status = if response.respond_to? :code
                    response.code
                  elsif response.respond_to? :status
                    response.status
                  end
        @body = response.body
      end

      @response = opts[:return_feed]
      @wrapped_exception = opts[:wrapped_exception]
    end
  end
end
