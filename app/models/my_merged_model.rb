class MyMergedModel
  include ActiveAttr::Model

  def initialize(uid)
    @uid = uid
  end

  def get_feed(*opts)
    Rails.cache.fetch(
        self.class.cache_key(@uid),
        :expires_in => Settings.cache.api_expires_in,
        :race_condition_ttl => 2.seconds
    ) do
      get_feed_internal(*opts)
    end
  end

  def self.cache_key(uid)
    key = "user/#{uid}/#{self.name}"
    logger.debug "#{self.name} cache_key will be #{key}"
    key
  end

  def self.expire(uid)
    Rails.cache.delete(cache_key(uid), :force => true)
  end

  def expire_cache
    self.class.expire(@uid)
  end
end
