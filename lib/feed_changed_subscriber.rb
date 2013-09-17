class FeedChangedSubscriber < TorqueBox::Messaging::MessageProcessor

  include ClassLogger

  def on_message(body)
    logger.debug "Got TorqueBox message: body = #{body.inspect}, message = #{message.inspect}"

  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

end
