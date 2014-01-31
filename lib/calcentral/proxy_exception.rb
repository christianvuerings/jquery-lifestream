module Calcentral
  class ProxyException < Exception
    attr_accessor :wrapped_exception, :log_message, :cache_key, :response

    def initialize(log_message=nil, cache_key=nil, response=nil, wrapped_exception=nil)
      @log_message = log_message
      @cache_key = cache_key
      @response = response
      @wrapped_exception = wrapped_exception
    end
  end
end
