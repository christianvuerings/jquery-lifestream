module Errors
  class ProxyError < StandardError
    attr_accessor :log_message, :response, :wrapped_exception

    def initialize(log_message = nil,
      response = nil,
      wrapped_exception = nil
    )
      @log_message = log_message
      @response = response
      @wrapped_exception = wrapped_exception
    end
  end
end
