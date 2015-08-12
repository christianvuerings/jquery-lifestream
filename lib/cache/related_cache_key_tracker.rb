module Cache
  module RelatedCacheKeyTracker

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def user_key(uid)
        "related-cache-keys-#{uid}"
      end

      def expire(uid=nil)
        super uid
        keys = related_cache_keys uid
        logger.debug "Will now expire these associated keys for uid #{uid}: #{keys}"
        keys.keys.each do |key|
          Rails.cache.delete key
        end
        Rails.cache.delete(user_key(uid))
      end

      def related_cache_keys(uid=nil)
        Rails.cache.read(user_key(uid)) || {}
      end

      def save_related_cache_key(uid=nil, related_key=nil)
        keys = related_cache_keys uid
        return if keys[related_key].present?
        keys[related_key] = 1
        logger.debug "Writing related keys for uid #{uid}: #{keys}"
        Rails.cache.write(user_key(uid),
                          keys,
                          :expires_in => Settings.maximum_expires_in,
                          :force => true)
      end
    end
  end
end
