class RegStatusEventProcessor < AbstractEventProcessor

  def accept?(event)
    return false unless super event
    event["code"] == "RegStatus"
  end

  def process_internal(event, timestamp)
    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid

    return [] unless reg_status != nil

    if reg_status["reg_status_cd"].upcase == "Z"
      # code Z, student deceased, remove from our system
      UserApi.delete "#{uid}"
      return []
    end

    [Notification.new({
                          :uid => uid,
                          :data => {
                              :event => event,
                              :timestamp => timestamp,
                              :reg_status => reg_status
                          },
                          :translator => "RegStatusTranslator"})]
  end

end

