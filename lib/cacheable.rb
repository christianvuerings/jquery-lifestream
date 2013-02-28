module Calcentral

  module Cacheable

    def expires_in
      expirations = Settings.cache.expiration.marshal_dump
      expirations[self.name.to_sym] || Settings.cache.expiration.default
    end

    def cache_key(uid)
      key = "user/#{uid}/#{self.name}"
      Rails.logger.debug "#{self.name} cache_key will be #{key}"
      key
    end

    def global_cache_key()
      key = "global/#{self.name}"
      Rails.logger.debug "#{self.name} cache_key will be #{key}"
    end

    def expire(uid)
      key = self.cache_key uid
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
    end

  end

end
