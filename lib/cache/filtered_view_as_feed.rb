# API feeds should not expose certain types of data (basically anything from Google apps) in
# view-as sessions. In other ways, however, we need to make view-as as realistic as possible.
# The minority of dangerous API feeds inherit from this class and filter their feeds.
# This will lose the benefits of JSON-layer caching, but should preserve other behavior.

module Cache
  module FilteredViewAsFeed
    # The API merged model should override this method to censor the feed.
    def filter_for_view_as(feed)
      feed
    end

    def get_feed_as_json(force_cache_write=false)
      if directly_authenticated?
        super(force_cache_write)
      else
        feed = get_feed(force_cache_write)
        filter_for_view_as(feed).to_json
      end
    end
  end
end
