class RegStatusTranslator

  def accept?(event)
    event["code"] == "RegStatus"
  end

  def translate(notification)
    data = notification.data
    uid = notification.uid
    event = data["event"]
    begin
      timestamp = Time.parse(data["timestamp"]).to_datetime
    rescue
      timestamp = notification.created_at
    end
    reg_status = data["reg_status"]

    Rails.logger.info "#{self.class.name} translating: #{notification}; accept? #{accept?(event)}; timestamp = #{timestamp}; uid = #{uid}; reg_status = #{reg_status}"

    return false unless accept?(event) && (payload = event["payload"]) && timestamp && uid && reg_status

    explanation = status_explanation reg_status["reg_status_cd"]
    status = status reg_status["reg_status_cd"]

    title = "Registration status updated to: #{status}"
    summary = "#{explanation} If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"

    {
        :id => notification.id,
        :title => title,
        :summary => summary,
        :source => event["system"],
        :type => "alert",
        :date => {
            :epoch => timestamp.to_i,
            :datetime => timestamp.rfc3339,
            :date_string => timestamp.strftime("%-m/%d")
        },
        :url => "https://bearfacts.berkeley.edu/bearfacts/",
        :source_url => "https://bearfacts.berkeley.edu/bearfacts/",
        :emitter => "Campus",
        :color_class => "campus-item"
    }
  end

  def status(reg_status)
    admincancelled = "ADMIN CANCELLED"
    cancelled = "CANCELLED"
    dismissed = "DISMISSED"
    registered = "REGISTERED"
    unregistered = "NOT REGISTERED"
    withdrawn = "WITHDRAWN"

    if reg_status == nil
      return nil
    end

    case reg_status.upcase
      when ""
        unregistered
      when "A"
        unregistered
      when "C"
        registered
      when "L"
        registered
      when "N"
        registered
      when "R"
        registered
      when "V"
        registered
      when "D"
        dismissed
      when "U"
        admincancelled
      when "X"
        cancelled
      when "Z"
        unregistered
      when "W"
        withdrawn
      when "S"
        registered
      else
        unregistered
    end
  end

  def status_explanation(reg_status)

    if reg_status == nil
      return nil
    end

    # TODO resolve gaps and ??? marks - CLC-1069
    unregistered = "In order to be officially registered, you must pay at least 20% of your registration fees, have no outstanding blocks, and be enrolled in at least one class."
    registered = "You are officially registered for this term and are entitled to access campus services."

    case reg_status.upcase
      when ""
        unregistered
      when "A"
        unregistered
      when "C"
        registered
      when "L"
        registered
      when "N"
        registered
      when "R"
        registered
      when "V"
        registered
      when "D"
        'You have been academically dismissed for this term.'
      when "U"
        'You have been administratively cancelled for this term.'
      when "X"
        'Your registration has been canceled for this term.'
      when "Z"
        'The Office of the Registrar has been notified of the death of this student ID.'
      when "W"
        'You are withdrawn for this term and may owe fees depending on your date of withdrawal.'
      when "S"
        registered
      else
        'Unknown Status.'
    end
  end
end

