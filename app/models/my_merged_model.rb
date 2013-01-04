require 'lib/cacheable.rb'

class MyMergedModel
  include ActiveAttr::Model
  extend Calcentral::Cacheable

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

  def expire_cache
    self.class.expire(@uid)
  end
end
