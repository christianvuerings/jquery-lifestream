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
    notifications = process_internal(event, timestamp)

    if notifications.empty?
      return false
    end

    notifications.each do |notification|
      if UserData.where(:uid => "#{notification.uid}").exists?
        notification.save
        Calcentral::USER_CACHE_EXPIRATION.notify notification.uid
      else
        Rails.logger.debug "#{self.class.name} Skipping user #{notification.uid} that does not exist in our user table"
      end
    end
    true

  end

  def is_dupe?(uid, event, timestamp, type)
    # check that we're not inserting a duplicate Notification on the same day
    start_date = timestamp.to_date
    end_date = start_date.advance(:days => 1)
    dupe = Notification.where(:uid => uid, :translator => type, :occurred_at => start_date...end_date)
    if dupe.empty?
      false
    else
      Rails.logger.info "#{self.class.name} We got a duplicate notification, skipping. Event: #{event}"
      true
    end
  end

end
