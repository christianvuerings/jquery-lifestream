class MyMergedModel
  include ActiveAttr::Model, ClassLogger
  extend Calcentral::Cacheable

  def initialize(uid, options={})
    @uid = uid
    @options = options
    if options
      @original_uid = options[:original_user_id]
    end
  end

  def init
    # override to do any initialization that requires database access or other expensive computation.
    # If you do expensive work from initialize, it will happen even when this object is cached -- not desirable!
  end

  def get_feed(*opts)
    uid = @uid
    uid = Calcentral::PSEUDO_USER_PREFIX + @uid if is_acting_as_nonfake_user?

    self.class.fetch_from_cache uid do
      init
      feed = get_feed_internal(*opts)
      notify_if_feed_changed(feed, uid)
      feed
    end
  end

  def notify_if_feed_changed(feed, uid)
    last_modified = self.class.get_last_modified uid
    old_hash = last_modified ? last_modified[:hash] : ""
    last_modified[:hash] = Digest::SHA1.hexdigest(feed.to_json)

    # has content changed? if so, save last_modified to cache and trigger a message
    if old_hash != last_modified[:hash]
      last_modified[:timestamp] = Time.now.to_i
      feed_name = self.class.name.to_s
      Rails.cache.write(self.class.last_modified_cache_key(uid), last_modified, :expires_in => 28.days)
      logger.debug "Last_modified hash has changed, sending feed changed message for #{feed_name}, uid #{uid}, hash #{last_modified[:hash]}"
      Calcentral::Messaging.publish('/queues/feed_changed', {:feed => feed_name, :uid => uid})
    end
  end

  def self.get_last_modified(uid)
    Rails.cache.fetch(self.last_modified_cache_key(uid), :expires_in => 28.days) do
      {
        :hash => '',
        :timestamp => 0
      }
    end
  end

  def self.last_modified_cache_key(uid)
    "user/#{uid}/#{self.name}/LastModified"
  end

  def expire_cache
    self.class.expire(@uid)
  end

  def is_acting_as_nonfake_user?
    @original_uid && @uid != @original_uid && !UserAuth.is_test_user?(@uid)
  end

end
