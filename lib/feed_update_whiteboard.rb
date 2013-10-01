class FeedUpdateWhiteboard < TorqueBox::Messaging::MessageProcessor

  include ClassLogger
  extend Calcentral::Cacheable

  def on_message(uid)
    unless uid
      logger.warn "Got empty TorqueBox message; skipping"
      return
    end

    logger.warn "Processing feed_changed message: uid = #{uid}"
    self.class.update_whiteboard(uid)
  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

  def self.get_whiteboard(uid)
    self.fetch_from_cache uid do
      self.update_whiteboard(uid)
    end
  end

  def self.expires_in
    0
  end

  def self.update_whiteboard(uid)
    # we don't want to write the board state out too often.
    Rails.cache.fetch(self.key("FeedUpdateWhiteboard/UpdateRequestRateLimiter-#{uid}"),
                      :expires_in => Settings.cache.feed_update_refresh_interval) do
      whiteboard = {}
      Calcentral::MERGED_FEEDS.values.each do |feed|
        whiteboard[feed.name] = feed.get_last_modified(uid)
      end
      Rails.cache.write(self.cache_key(uid), whiteboard)
      whiteboard
    end
  end

end
