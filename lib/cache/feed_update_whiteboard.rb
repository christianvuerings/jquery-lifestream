module Cache
  class FeedUpdateWhiteboard < TorqueBox::Messaging::MessageProcessor

    include ClassLogger
    extend Cache::Cacheable

    def on_message(uid)
      unless uid
        logger.warn "Got empty TorqueBox message; skipping"
        return
      end

      logger.warn "Processing feed_changed message: uid = #{uid}"
      self.class.expire(uid)
    end

    def on_error(exception)
      logger.error "Got an exception handling a message: #{exception.inspect}"
      raise exception
    end

    def self.get_whiteboard(uid)
      self.fetch_from_cache uid do
        whiteboard = {}
        Cache::LiveUpdatesEnabled.classes.each do |feed|
          whiteboard[feed.name] = feed.get_last_modified(uid)
        end
        whiteboard
      end
    end

  end
end
