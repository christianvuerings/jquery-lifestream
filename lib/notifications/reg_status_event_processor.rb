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

    if reg_status["reg_status_cd"].upcase == "Z"
      # code Z, student deceased, remove from our system
      UserApi.delete "#{uid}"
      return false
    end

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
    Calcentral::USER_CACHE_EXPIRATION.notify uid
    true

  end

end

