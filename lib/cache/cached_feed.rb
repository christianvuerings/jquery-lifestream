module Cache
  module CachedFeed
    def self.included(klass)
      klass.extend Cache::Cacheable
    end

    def init
      # override to do any initialization that requires database access or other expensive computation.
      # If you do expensive work from initialize, it will happen even when this object is cached -- not desirable!
    end

    def get_feed(force_cache_write=false)
      key = instance_key
      self.class.fetch_from_cache(key, force_cache_write) do
        init
        get_feed_internal
      end
    end

    def get_feed_as_json(force_cache_write=false)
      get_feed(force_cache_write).to_json
    end

    def expire_cache
      self.class.expire(instance_key)
    end

  end
end
