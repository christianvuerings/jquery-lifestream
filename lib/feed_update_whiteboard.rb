class FeedUpdateWhiteboard < TorqueBox::Messaging::MessageProcessor

  include ClassLogger
  extend Calcentral::Cacheable

  def on_message(body)
    logger.debug "Got TorqueBox message: body = #{body.inspect}, message = #{message.inspect}"
    feed_name = body[:feed]
    feed_class = MyMergedModel.subclasses[feed_name]

    uid = body[:uid]
    whiteboard = self.class.get_whiteboard(uid)
    last_updated = feed_class.get_last_modified(uid)
    whiteboard[feed_name] = last_updated
    Rails.cache.write(self.class.cache_key(uid), whiteboard)
  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

  def self.get_whiteboard(uid)
    self.fetch_from_cache uid do
      {
      }
    end
  end

end
