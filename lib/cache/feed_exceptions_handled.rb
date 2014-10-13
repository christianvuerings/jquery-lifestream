module Cache
  module FeedExceptionsHandled

    # The text to be shown to the end user.
    def default_message_on_exception
      nil
    end

    # Uses "smart_fetch_from_cache" for its exception handling.
    def get_feed(force_cache_write=false)
      key = instance_key
      self.class.smart_fetch_from_cache({
        id: key,
        force_write: force_cache_write,
        user_message_on_exception: default_message_on_exception
      }) do
        init
        get_feed_internal
      end
    end

  end
end
