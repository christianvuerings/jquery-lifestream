class AbstractModel

  include ActiveAttr::Model, ClassLogger, DatedFeed
  extend Cache::Cacheable

  def initialize(id, options={})
    @id = id
    @options = options
  end

  def init
    # override to do any initialization that requires database access or other expensive computation.
    # If you do expensive work from initialize, it will happen even when this object is cached -- not desirable!
  end

  # Bring the cache reasonably up-to-date. By default, "reasonably" means every time warming
  # is requested. However, certain user-visible feeds may need to reduce traffic on data sources.
  def warm_cache
    get_feed_as_json(true)
  end

  def get_feed(force_cache_write=false)
    key = instance_key
    self.class.fetch_from_cache(key, force_cache_write) do
      init
      feed = get_feed_internal
      feed.merge(feed_metadata(feed, key))
    end
  end

  def get_feed_as_json(force_cache_write=false)
    if self.class.caches_separate_json?
      # cache the JSONified feed for maximum efficiency when we're called by a controller.
      self.class.fetch_from_cache(self.class.json_key(instance_key), force_cache_write) do
        get_feed(force_cache_write).to_json
      end
    else
      get_feed(force_cache_write).to_json
    end
  end

  def feed_metadata(feed, key)
    last_modified = notify_if_feed_changed(feed, key)
    {
      lastModified: last_modified,
      feedName: self.class.name
    }
  end

  def notify_if_feed_changed(feed, key)
    last_modified = self.class.get_last_modified key
    old_hash = last_modified ? last_modified[:hash] : ""
    last_modified[:hash] = Digest::SHA1.hexdigest(feed.to_json)

    # has content changed? if so, save last_modified to cache and trigger a message
    if old_hash != last_modified[:hash]
      last_modified[:timestamp] = format_date(Time.now.to_datetime)
      Rails.cache.write(self.class.last_modified_cache_key(key), last_modified, :expires_in => 28.days)
      Rails.cache.fetch(self.class.feed_changed_rate_limiter(key), :expires_in => 10.seconds) do
        Messaging.publish('/queues/feed_changed', key)
        true
      end
    end
    last_modified
  end

  def self.get_last_modified(key)
    Rails.cache.fetch(self.last_modified_cache_key(key), :expires_in => 28.days) do
      {
        :hash => '',
        :timestamp => format_date(DateTime.new(0))
      }
    end
  end

  def self.last_modified_cache_key(key)
    "user/#{key}/#{self.name}/LastModified"
  end

  def self.feed_changed_rate_limiter(key)
    "user/#{key}/FeedChangedRateLimiter"
  end

  def instance_key
    @id
  end

  def expire_cache
    self.class.expire(instance_key)
  end

  def self.caches_separate_json?
    true
  end

  def self.json_key(id)
    "json-#{id}"
  end

  def self.expire(id = nil)
    super(id)
    if caches_separate_json?
      key = cache_key(json_key(id))
      Rails.cache.delete(key, :force => true)
      Rails.logger.debug "Expired cache_key #{key}"
    end
  end

end
