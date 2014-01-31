module Calcentral

  module Cacheable

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
