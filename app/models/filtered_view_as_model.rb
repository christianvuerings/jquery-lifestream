# API feeds should not expose certain types of data (basically anything from Google apps) in
# view-as sessions. In other ways, however, we need to make view-as as realistic as possible.
# The minority of dangerous API feeds inherit from this class and filter their feeds.
# This will lose the benefits of JSON-layer caching, but should preserve other behavior.

class FilteredViewAsModel < UserSpecificModel
  # The API merged model should override this method to censor the feed.
  def filter_for_view_as(feed)
    feed
  end

  def get_feed_as_json(force_cache_write=false)
    if indirectly_authenticated?
      feed = get_feed(force_cache_write)
      filter_for_view_as(feed).to_json
    else
      super(force_cache_write)
    end
  end

end
