class MyMergedModel
  include ActiveAttr::Model, ClassLogger, DatedFeed
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
    uid = effective_uid
    self.class.fetch_from_cache uid do
      init
      feed = get_feed_internal(*opts)
      last_modified = notify_if_feed_changed(feed, uid)
      feed[:last_modified] = last_modified
      feed[:last_modified][:timestamp] = format_date(Time.at(last_modified[:timestamp]).to_datetime)
      feed
    end
  end

  def get_feed_as_json(*opts)
    # cache the JSONified feed for maximum efficiency when we're called by a controller.
    self.class.fetch_from_cache "json-#{effective_uid}" do
      feed = get_feed(*opts)
      feed.to_json
    end
  end

  def notify_if_feed_changed(feed, uid)
    last_modified = self.class.get_last_modified uid
    old_hash = last_modified ? last_modified[:hash] : ""
    last_modified[:hash] = Digest::SHA1.hexdigest(feed.to_json)

    # has content changed? if so, save last_modified to cache and trigger a message
    if old_hash != last_modified[:hash]
      last_modified[:timestamp] = Time.now.to_i
      Rails.cache.write(self.class.last_modified_cache_key(uid), last_modified, :expires_in => 28.days)
      Calcentral::Messaging.publish('/queues/feed_changed', uid)
    end
    last_modified
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

  def self.caches_json?
    true
  end

  def expire_cache
    self.class.expire(@uid)
  end

  def is_acting_as_nonfake_user?
    @original_uid && @uid != @original_uid && !UserAuth.is_test_user?(@uid)
  end

  def effective_uid
    if is_acting_as_nonfake_user?
      Calcentral::PSEUDO_USER_PREFIX + @uid
    else
      @uid
    end
  end

end
