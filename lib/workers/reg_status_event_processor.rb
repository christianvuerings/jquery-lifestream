class RegStatusEventProcessor

  def accept?(event)
    event["code"] == "RegStatus"
  end

  def process(event, timestamp)
    return false unless accept?(event)
    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}"
    uid = event["payload"]["uid"]
    reg_status = CampusData.get_reg_status uid
    Rails.logger.debug "#{self.class.name} Reg_status for #{uid} is #{reg_status}"
    translation = translate_status reg_status["reg_status_cd"]
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
    # TODO resolve gaps and ??? marks - CLC-1069
    case reg_status.upcase
      when ""
        '"admitted / not registered." To complete your registration you must pay all registration fees, have no outstanding "blocks" and be enrolled in at least one course.'
      when "A"
        '"applied / not registered for Summer Session."  Check with summer session on you application status and if you have any outstanding fees owed.'
      when "C"
        '"registered, continuing." You are an active registered student in your second or subsequent semester.'
      when "L"
        '"registered, limited." You have all the privileges of student except ???'
      when "N"
        '"registered, new." Congratulations you have completed the admissions and registration steps and are now a newly admitted student.'
      when "R"
        '"registered, re-admitted." Readmission usually occurs after you have taken one or more semesters off, and following a withdrawal application, or if you took a semester to study abroad.'
      when "V"
        '"registered, visitor." You have been provided limited student privileges.'
      when "D"
        '"not registered, academic dismissed." You no longer have the privileges of a registered student. For more information, please contact the Office of Student Conduct.'
      when "F"
        '"not registered, incomplete (withdrawal)." Your request to withdraw from the current semester has been processed.'
      when "U"
        '"not registered, admin cancellation." You have completed your program or graduated.'
      when "I"
        '"registered, potential deletes." ?????'
      when "X"
        '"not registered, registration cancelled." Your cancellation request has been processed.'
      when "Y"
        '"registered, roster number changed." ?????'
      when "Z"
        '"not registered, deceased." The Office of the Registrar has been notified of the death of this student ID.'
      when "W"
        '"not registered, withdrawn." You have been withdrawn by a university official for one of the following reasons ????'
      when "S"
        '"registered for summer session." Congratulations you are registered for Summer Session classes.'
      else
        'Unknown Status.'
    end
  end
end

