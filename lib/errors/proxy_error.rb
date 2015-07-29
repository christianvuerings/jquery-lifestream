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

    def message
      properties = []
      properties << @log_message if @log_message
      properties << "#{@wrapped_exception.class} #{@wrapped_exception.message}" if @wrapped_exception
      properties << "url: #{@url}" if @url
      properties << "status: #{@status}" if @status
      properties.join('; ')
    end

    def uid_and_response_body
      message = ''
      message += "; uid: #{@uid}" if @uid
      message += ". Response body: #{@body}" if @body
      message
    end

    def to_s
      "#{message}#{uid_and_response_body}"
    end
  end
end
