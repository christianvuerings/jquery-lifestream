module Calcentral

  module Cacheable

    def fetch_from_cache(id = nil)
      key = id ? self.cache_key(id) : self.global_cache_key
      Rails.logger.debug "#{self.name} cache_key will be #{key}, expiration #{self.expires_in}"
      Rails.cache.fetch(
          key,
          :expires_in => self.expires_in
      ) do
        yield
      end
    end

    def expires_in
      expirations = Settings.cache.expiration.marshal_dump
      expirations[self.name.to_sym] || expirations[:default]
    end

    def cache_key(uid)
      "user/#{uid}/#{self.name}"
    end

    def global_cache_key()
      "global/#{self.name}"
    end

    def expire(uid)
      key = self.cache_key uid
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
    end

  end

end
