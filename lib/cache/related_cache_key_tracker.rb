module Cache
  module RelatedCacheKeyTracker

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def expire(uid=nil)
        super uid
        keys = related_cache_keys uid
        logger.debug "Will now expire these associated keys for uid #{uid}: #{keys}"
        keys.keys.each do |key|
          Rails.cache.delete key
        end
        Rails.cache.delete "additional-keys-#{uid}"
      end

      def related_cache_keys(uid=nil)
        Rails.cache.read("related-cache-keys-#{uid}") || {}
      end

      def save_related_cache_key(uid=nil, related_key=nil)
        keys = related_cache_keys uid
        return if keys[related_key].present?
        keys[related_key] = 1
        logger.debug "Writing related keys for uid #{uid}: #{keys}"
        Rails.cache.write("related-cache-keys-#{uid}",
                          keys,
                          :expires_in => Settings.maximum_expires_in,
                          :force => true)
      end
    end
  end
end
