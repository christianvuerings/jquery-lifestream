class RegStatusEventProcessor

  def accept?(event)
    event["code"] == "RegStatus"
  end

  def process(event, timestamp)
    return false unless accept?(event)
    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}"
    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid
    translation = translate_status reg_status["reg_status_cd"]
    Rails.logger.info "Translation = #{translation}"
    title = "Your UC Berkeley student registration status has been updated to: #{translation} If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"
    data = {
        :user_id => uid,
        :title => title,
        :summary => "summary TODO",
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

    notification = Notification.new({:uid => uid, :data => data})
    notification.save
    true
  end

  def translate_status(reg_status)
    # TODO fill in other status code translations.
    case
      when "C"
        '"registered, continuing." You are an active registered student in your second or subsequent semester.'
      else
        'Unknown Status.'
    end
  end
end

