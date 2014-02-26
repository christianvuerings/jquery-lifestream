module Calcentral

  module Cacheable

    # thin wrapper around Rails.cache.fetch. Reads the value of key from cache if it exists, otherwise executes
    # the passed block and caches the result. Set force_write=true to make it always execute the block and write
    # to the cache.
    def fetch_from_cache(id=nil, force_write=false)
      key = key id
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}, forced: #{force_write}"
      Rails.cache.fetch(
        key,
        :expires_in => self.expires_in,
        :force => force_write
      ) do
        if block_given?
          yield
        end
      end
    end

    # reads from cache if possible, otherwise executes the passed block and caches the result.
    # if the passed block throws an exception, it will be logged, and the result won't be cached.
    # WARNING: Do not use "return foo" inside the passed block or you will short-circuit the flow
    # and nothing will be cached.
    def smart_fetch_from_cache(id=nil,
      user_message_on_exception = "An unknown server error occurred.",
      return_nil_on_generic_error = false,
      force_write=false,
      &block)
      key = key id
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}"
      unless force_write
        entry = Rails.cache.read key
        if entry
          Rails.logger.debug "#{self.name} Entry is already in cache: #{key}"
          return entry
        end
      end
      begin
        entry = block.call
      rescue Exception => e
        # don't write to cache if an exception occurs, just log the error and return a body
        response = handle_exception(e, id, return_nil_on_generic_error, user_message_on_exception)
        Rails.logger.debug "#{self.name} Error occurred; NOT Writing entry to cache: #{key}"
        return response
      end
      Rails.logger.debug "#{self.name} Writing entry to cache: #{key}"
      Rails.cache.write(key,
                        entry,
                        :expires_in => self.expires_in,
                        :force => true)
      entry
    end

    def handle_exception(e, id, return_nil_on_generic_error, user_message_on_exception)
      key = key id
      if e.is_a?(Calcentral::ProxyError)
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
            :status_code => 503
          }
        end
      end
      log_message += " Associated cache key: #{key}"

      Rails.logger.error log_message
      response
    end

    def in_cache?(id = nil)
      key = key id
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
      today = Time.zone.today.to_time_in_current_zone.to_datetime.advance(:hours => 8)
      now = Time.zone.now
      if now.to_i > today.to_i
        tomorrow = today.advance(:days => 1)
        tomorrow.to_i
      else
        today.to_i
      end
    end

    def cache_key(uid)
      "user/#{uid}/#{self.name}"
    end

    def global_cache_key()
      "global/#{self.name}"
    end

    def expire(id = nil)
      key = key id
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
      if caches_json?
        key = json_key id
        Rails.cache.delete(key, :force => true)
        Rails.logger.debug "Expired cache_key #{key}"
      end
    end

    def key(id = nil)
      id ? self.cache_key(id) : self.global_cache_key
    end

    def json_key(id = nil)
      key "json-#{id}"
    end

    # override to return true if your cacheable thing also caches a JSONified copy of its data.
    def caches_json?
      false
    end

  end

end
