class FinalGradesEventProcessor

  def accept?(event)
    event["code"] == "EndOFTermGrade"
  end

  def process(event, timestamp)
    return false unless accept?(event) && (payload = event["payload"])
    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}"

    ccn = payload["ccn"]
    term_yr = payload["year"]
    term_cd = lookup_term_code payload["term"]

    students = CampusData.get_enrolled_students(ccn, term_yr, term_cd)
    course = CampusData.get_course(ccn, term_yr, term_cd)

    return false unless students && course && course["course_title"]
    Rails.logger.debug "#{self.class.name} Found students enrolled in #{course} - #{term_yr}-#{term_cd}-#{ccn}: #{students}"

    if timestamp == nil
      timestamp = Time.now.to_datetime
    end

    data = {
        :event => event,
        :timestamp => timestamp,
        :course => course
    }

    students.each do |student|
      notification = Notification.new({:uid => student["ldap_uid"], :data => data, :translator => "FinalGradesTranslator"})
      notification.save
      Calcentral::USER_CACHE_EXPIRATION.notify student["ldap_uid"]
    end

    true
  end

  def lookup_term_code(term)
    case term.downcase
      when "spring"
        "B"
      when "summer"
        "C"
      when "fall"
        "D"
      else
        "D"
    end
  end

end
