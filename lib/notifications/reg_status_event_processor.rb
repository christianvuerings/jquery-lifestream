class RegStatusEventProcessor < AbstractEventProcessor

  def accept?(event)
    return false unless super event
    event["code"] == "RegStatus"
  end

  def process_internal(event, timestamp)
    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid

    if reg_status == nil
      Rails.logger.info "#{self.class.name} Registration status for #{uid} could not be determined, skipping event."
    end

    return [] unless reg_status != nil

    if reg_status["reg_status_cd"].upcase == "Z"
      # code Z, student deceased, remove from our system
      UserApi.delete "#{uid}"
      Rails.logger.info "#{self.class.name} Got a code Z indicating deceased student; removing #{uid} from system"
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

