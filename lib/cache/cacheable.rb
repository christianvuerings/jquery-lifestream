module Cache

  module Cacheable
    include ResponseWrapper

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
      key = cache_key id
      force_write = opts[:force_write]
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}"
      unless force_write
        entry = Rails.cache.read key
        if entry
          Rails.logger.debug "#{self.name} Entry is already in cache: #{key}"
          return (entry == NilClass) ? nil : entry
        end
      end
      wrapped_response = handling_exceptions(key, opts, &block)
      response = wrapped_response[:response]
      cached_entry = (response.nil?) ? NilClass : response
      if wrapped_response[:exception]
        Rails.logger.debug "#{self.name} Error occurred; writing entry to cache with short lifespan: #{key}"
        expiration = Settings.cache.expiration.failure
      else
        Rails.logger.debug "#{self.name} Writing entry to cache: #{key}"
        expiration = self.expires_in
      end
      Rails.cache.write(key,
                        cached_entry,
                        :expires_in => expiration,
                        :force => true)
      response
    end

    def in_cache?(id = nil)
      key = cache_key id
      Rails.cache.exist? key
    end

    def expires_in
      expirations = Settings.cache.expiration.marshal_dump
      exp = expirations[self.name.to_sym] || expirations[:default]
      exp = parse_expiration_setting(exp)
      [exp, Settings.cache.maximum_expires_in].min
    end

    def parse_expiration_setting(exp)
      if exp.is_a?(String) && (parsed = /NEXT_(?<hour>\d+)_(?<minute>\d+)/.match(exp))
        hour = parsed[:hour]
        next_time = Time.zone.today.in_time_zone.to_datetime.advance(hours: parsed[:hour].to_i,
          minutes: parsed[:minute].to_i)
        now = Time.zone.now.to_i
        if now > next_time.to_i
          next_time = next_time.advance(days: 1)
        end
        next_time.to_i - now
      else
        exp
      end
    end

    def bearfacts_derived_expiration
      # Bearfacts data is refreshed daily at 0730, so we will always expire at 0800 sharp on the day after today.
      parse_expiration_setting('NEXT_08_00')
    end

    def expire(id = nil)
      key = cache_key id
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
    end

    def cache_key(id = nil)
      id.nil? ? self.name : "#{self.name}/#{id}"
    end

    def write_cache(value, id = nil)
      Rails.cache.write(cache_key(id),
        value,
        :expires_in => self.expires_in,
        :force => true)
    end

  end

end
