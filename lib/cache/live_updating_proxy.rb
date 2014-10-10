# Combine Live Updates support along with short cache expiration times when the data source
# throws an exception. This is meant to support straight-through single-source user-visible
# feeds, and is less suitable for APIs which merge multiple feeds, each with its own cache.
module Cache
  module LiveUpdatingProxy
    def self.included(klass)
      klass.extend ClassMethods
    end

    # The text to be shown to the end user.
    def default_message_on_exception
      nil
    end

    # Uses "smart_fetch_from_cache" for its exception handling.
    def get_feed(force_cache_write=false)
      key = instance_key
      # self.class.fetch_from_cache(key, force_cache_write) do
      self.class.smart_fetch_from_cache({
        id: key,
        force_write: force_cache_write,
        user_message_on_exception: default_message_on_exception
      }) do
        init
        get_feed_internal
      end
    end

    module ClassMethods

      def jsonify_feed
        false
      end

      # Decorates the vanilla feed response with Live Updates metadata.
      def handling_exceptions(feed_key, opts={}, &block)
        wrapped_response = super(feed_key, opts, &block)
        feed = wrapped_response[:response]
        feed_for_live_update = feed.merge(feed_metadata(feed, opts[:id]))
        feed_for_live_update = feed_for_live_update.to_json if jsonify_feed
        wrapped_response[:response] = feed_for_live_update
        wrapped_response
      end

    end

  end
end
