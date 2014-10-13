module Cache
  module LiveUpdatesEnabled
    include Cache::CachedFeed

    def self.included(klass)
      @classes ||= []
      @classes << klass
      klass.extend Cache::Cacheable
      klass.extend ClassMethods
      klass.class_eval do
        include ClassLogger, DatedFeed
      end
    end

    def self.classes
      unless @classes
        # in TorqueBox messaging context, we have to eager_load! for ourselves,
        # otherwise the @classes array will remain nil forever.
        Rails.application.eager_load!
      end
      @classes
    end

    # A value of "true" means to overwrite the current cached value whenever warming is
    # requested, never returning stale data. This is generally the best setting for merged
    # models built out of multiple feeds which each have their own cache lifespans.
    # A value of "false" uses standard caching for update checks. This is generally the best
    # setting for straight-through feeds.
    def freshen_on_warm
      false
    end

    # Bring the cache reasonably up-to-date. By default, "reasonably" means every time warming
    # is requested. However, certain user-visible feeds may need to reduce traffic on data sources.
    def warm_cache
      get_feed(freshen_on_warm)
    end

    module ClassMethods

      # Decorate the basic feed with Live Updates metadata.
      def process_response_before_caching(response, opts)
        if response.respond_to?(:merge)
          response = response.merge(self.feed_metadata(response, opts[:id]))
        end
        super(response, opts)
      end

      def feed_metadata(feed, key)
        last_modified = notify_if_feed_changed(feed, key)
        {
          lastModified: last_modified,
          feedName: self.name
        }
      end

      def notify_if_feed_changed(feed, key)
        last_modified = get_last_modified key
        old_hash = last_modified ? last_modified[:hash] : ""
        last_modified[:hash] = Digest::SHA1.hexdigest(feed.to_json)

        # has content changed? if so, save last_modified to cache and trigger a message
        logger.debug "old = #{old_hash}, last = #{last_modified}"
        if old_hash != last_modified[:hash]
          last_modified[:timestamp] = format_date(Time.now.to_datetime)
          Rails.cache.write(last_modified_cache_key(key), last_modified, :expires_in => 28.days)
          Rails.cache.fetch(feed_changed_rate_limiter(key), :expires_in => 10.seconds) do
            Messaging.publish('/queues/feed_changed', key)
            true
          end
        end
        last_modified
      end

      def get_last_modified(key)
        Rails.cache.fetch(self.last_modified_cache_key(key), :expires_in => 28.days) do
          {
            :hash => '',
            :timestamp => format_date(DateTime.new(0))
          }
        end
      end

      def last_modified_cache_key(key)
        "user/#{key}/#{self.name}/LastModified"
      end

      def feed_changed_rate_limiter(key)
        "user/#{key}/FeedChangedRateLimiter"
      end
    end

  end
end
