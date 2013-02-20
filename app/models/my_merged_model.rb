require 'lib/cacheable.rb'

class MyMergedModel
  include ActiveAttr::Model
  extend Calcentral::Cacheable

  def initialize(uid, options={})
    @uid = uid
    if options
      @original_uid = options[:original_user_id]
    end
  end

  def get_feed(*opts)
    uid = @uid
    uid = Calcentral::PSEUDO_USER_PREFIX.concat(@uid) if is_acting_as_nonfake_user?

    Rails.cache.fetch(
        self.class.cache_key(uid),
        :expires_in => Settings.cache.api_expires_in,
        :race_condition_ttl => 2.seconds
    ) do
      get_feed_internal(*opts)
    end
  end

  def expire_cache
    self.class.expire(@uid)
  end

  def is_acting_as_nonfake_user?
    @original_uid && @uid != @original_uid && !UserData.is_test_user?(@uid)
  end

end
