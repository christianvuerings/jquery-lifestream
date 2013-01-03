module Calcentral

  module Cacheable

    def cache_key(uid)
      key = "user/#{uid}/#{self.name}"
      Rails.logger.debug "#{self.name} cache_key will be #{key}"
      key
    end

    def expire(uid)
      key = self.cache_key uid
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
    end

  end

end
