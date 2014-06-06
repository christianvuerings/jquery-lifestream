module Cache

  module Cacheable

    # thin wrapper around Rails.cache.fetch. Reads the value of key from cache if it exists, otherwise executes
    # the passed block and caches the result. Set force_write=true to make it always execute the block and write
    # to the cache.
    def fetch_from_cache(id=nil, force_write=false)
      key = cache_key id
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}, forced: #{force_write}"
      value = Rails.cache.fetch(
        key,
        :expires_in => self.expires_in,
        :force => force_write
      ) do
        if block_given?
          new_value = yield
          new_value.nil? ? NilClass : new_value
        end
      end
      (value == NilClass) ? nil : value
    end

    # reads from cache if possible, otherwise executes the passed block and caches the result.
    # if the passed block throws an exception, it will be logged, and the result won't be cached.
    # WARNING: Do not use "return foo" inside the passed block or you will short-circuit the flow
    # and nothing will be cached.
    def smart_fetch_from_cache(opts={}, &block)
      id = opts[:id]
      user_message_on_exception = opts[:user_message_on_exception] || "An unknown server error occurred"
      return_nil_on_generic_error = opts[:return_nil_on_generic_error]
      jsonify = opts[:jsonify]
      force_write = opts[:force_write]
      key = cache_key id
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}"
      unless force_write
        entry = Rails.cache.read key
        if entry
          Rails.logger.debug "#{self.name} Entry is already in cache: #{key}"
          return (entry == NilClass) ? nil : entry
        end
      end
      begin
        entry = block.call
        entry = entry.to_json if jsonify
      rescue => e
        # when an exception occurs, write with a short expiration time, log an error, and return the body with error info
        response = handle_exception(e, id, return_nil_on_generic_error, user_message_on_exception)
        response = response.to_json if jsonify
        Rails.logger.debug "#{self.name} Error occurred; writing entry to cache with short lifespan: #{key}"
        cached_response = (response.nil?) ? NilClass : response
        Rails.cache.write(key,
                          cached_response,
                          :expires_in => Settings.cache.expiration.failure,
                          :force => true)
        return response
      end
      Rails.logger.debug "#{self.name} Writing entry to cache: #{key}"
      cached_entry = (entry.nil?) ? NilClass : entry
      Rails.cache.write(key,
                        cached_entry,
                        :expires_in => self.expires_in,
                        :force => true)
      entry
    end

    def handle_exception(e, id, return_nil_on_generic_error, user_message_on_exception)
      key = cache_key id
      if e.is_a?(Errors::ProxyError)
        log_message = e.log_message
        response = e.response
        if e.wrapped_exception
          log_message += " #{e.wrapped_exception.class} #{e.wrapped_exception.message}."
        end
      else
        log_message = " #{e.class} #{e.message}"
        if return_nil_on_generic_error
          response = nil
        else
          response = {
            :body => user_message_on_exception,
            :statusCode => 503
          }
        end
      end
      log_message += " Associated cache key: #{key}"

      Rails.logger.error(log_message + "\n" + e.backtrace.join("\n "))
      response
    end

    def in_cache?(id = nil)
      key = cache_key id
      Rails.cache.exist? key
    end

    def expires_in
      expirations = Settings.cache.expiration.marshal_dump
      exp = expirations[self.name.to_sym] || expirations[:default]
      [exp, Settings.cache.maximum_expires_in].min
    end

    def bearfacts_derived_expiration
      # Bearfacts data is refreshed daily at 0730, so we will always expire at 0800 sharp on the day after today.
      # nb: memcached interprets expiration values greater than 30 days worth of seconds as a Unix timestamp. This
      # logic may not work on caching systems other than memcached.
      today = Time.zone.today.in_time_zone.to_datetime.advance(:hours => 8)
      now = Time.zone.now
      if now.to_i > today.to_time.to_i
        tomorrow = today.advance(:days => 1)
        tomorrow.to_time.to_i
      else
        today.to_time.to_i
      end
    end

    def expire(id = nil)
      key = cache_key id
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
      if caches_json?
        key = json_key id
        Rails.cache.delete(key, :force => true)
        Rails.logger.debug "Expired cache_key #{key}"
      end
    end

    def cache_key(id = nil)
      id.nil? ? self.name : "#{self.name}/#{id}"
    end

    def json_key(id = nil)
      cache_key "json-#{id}"
    end

    # override to return true if your cacheable thing also caches a JSONified copy of its data.
    def caches_json?
      false
    end

  end

end
