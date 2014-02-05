module Calcentral
  class ProxyException < Exception
    attr_accessor :wrapped_exception, :log_message, :response

    def initialize(log_message=nil, response=nil, wrapped_exception=nil)
      @log_message = log_message
      @response = response
      @wrapped_exception = wrapped_exception
    end
  end
end
