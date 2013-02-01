class AbstractEventProcessor

  def accept?(event)
    event["payload"] != nil
  end

  def process(event, timestamp)
    return false unless accept?(event)

    if timestamp == nil
      timestamp = Time.now.to_datetime
    end

    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}"
    process_internal(event, timestamp)
  end

end
