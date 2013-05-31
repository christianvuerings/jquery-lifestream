class AbstractEventProcessor
  include ActiveRecordHelper

  def accept?(event)
    event["payload"] != nil
  end

  def process(event, timestamp)
    return false unless accept?(event)
    timestamp ||= Time.now.to_datetime

    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}"
    notifications = process_internal(event, timestamp)

    return false if notifications.empty?

    # Using one connection for all the notification saves.
    use_pooled_connection {
      notifications.each do |notification|
        if UserData.where(:uid => "#{notification.uid}").exists?
          notification.save
          Calcentral::USER_CACHE_EXPIRATION.notify notification.uid
        else
          Rails.logger.debug "#{self.class.name} Skipping user #{notification.uid} that does not exist in our user table"
        end
      end
    }
    true

  end

  def is_dupe?(uid, event, timestamp, type)
    # check that we're not inserting a duplicate Notification on the same day
    start_date = timestamp.midnight
    end_date = start_date.advance(:days => 1)
    dupe = []
    use_pooled_connection {
      dupe = Notification.where(:uid => uid.to_s, :translator => type, :occurred_at => start_date...end_date)
    }
    if dupe.empty?
      false
    else
      Rails.logger.info "#{self.class.name} We got a duplicate notification, skipping. Event: #{event}"
      true
    end
  end

end
