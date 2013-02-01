class RegStatusEventProcessor < AbstractEventProcessor

  def accept?(event)
    return false unless super event
    event["code"] == "RegStatus"
  end

  def process_internal(event, timestamp)
    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid

    return false unless reg_status != nil

    if reg_status["reg_status_cd"].upcase == "Z"
      # code Z, student deceased, remove from our system
      UserApi.delete "#{uid}"
      return false
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

