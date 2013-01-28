class RegStatusEventProcessor

  def accept?(event)
    event["code"] == "RegStatus"
  end

  def process(event, timestamp)
    return false unless accept?(event)

    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid
    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}; reg_status = #{reg_status}"

    return false unless reg_status != nil

    if timestamp == nil
      timestamp = Time.now.to_datetime
    end

    data = {
        :event => event,
        :timestamp => timestamp,
        :reg_status => reg_status
    }

    notification = Notification.new({:uid => uid, :data => data, :translator => "RegStatusTranslator"})
    notification.save
    true

  end

end

