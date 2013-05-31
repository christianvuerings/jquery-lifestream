class RegStatusTranslator
  include DatedFeed

  def accept?(event)
    event && event['topic'] == "Bearfacts:RegStatus"
  end

  def translate(notification)
    data = notification.data
    uid = notification.uid
    event = data["event"]
    timestamp = notification.occurred_at.to_datetime
    reg_status = data["reg_status"]

    Rails.logger.info "#{self.class.name} translating: #{notification}; accept? #{accept?(event)}; timestamp = #{timestamp}; uid = #{uid}; reg_status = #{reg_status}"

    return false unless accept?(event) && timestamp && uid && reg_status

    explanation = notification_status_explanation reg_status["reg_status_cd"]
    status = status reg_status["reg_status_cd"]

    title = "Registration status updated to: #{status}"
    summary = "#{explanation} If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"

    {
        :id => notification.id,
        :title => title,
        :summary => summary,
        :source => event["topic"],
        :type => "alert",
        :date => format_date(timestamp),
        :url => "https://bearfacts.berkeley.edu/bearfacts/",
        :source_url => "https://bearfacts.berkeley.edu/bearfacts/",
        :emitter => "Campus",
        :color_class => "campus-item"
    }
  end

  def status(reg_status)
    admincancelled = "Administratively Cancelled"
    cancelled = "Cancelled"
    dismissed = "Dismissed"
    registered = "Registered"
    unregistered = "Not Registered"
    withdrawn = "Withdrawn"

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

  def is_registered(reg_status)
    if reg_status == nil
      return false
    end

    ["C", "L", "N", "R", "S", "V"].include?(reg_status.upcase)
  end

  def notification_status_explanation(reg_status)

    if reg_status == nil
      return nil
    end

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

  def status_explanation(reg_status)
    if reg_status == nil
      return nil
    end

    if is_registered(reg_status)
      ''
    else
      '<a href="http://registrar.berkeley.edu/FAQS.html">About registration status</a>'
    end
  end
end

