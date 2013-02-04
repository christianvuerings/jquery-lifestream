class FinalGradesEventProcessor < AbstractEventProcessor

  def accept?(event)
    return false unless super event
    event["code"] == "EndOFTermGrade"
  end

  def process_internal(event, timestamp)
    payload = event["payload"]
    ccn = payload["ccn"]
    term_yr = payload["year"]
    term_cd = lookup_term_code payload["term"]

    students = CampusData.get_enrolled_students(ccn, term_yr, term_cd)
    course = CampusData.get_course(ccn, term_yr, term_cd)

    return [] unless students && course && course["course_title"]
    Rails.logger.debug "#{self.class.name} Found students enrolled in #{course} - #{term_yr}-#{term_cd}-#{ccn}: #{students}"

    notifications = []
    students.each do |student|
      notifications.push Notification.new(
                             {
                                 :uid => student["ldap_uid"],
                                 :data => {
                                     :event => event,
                                     :timestamp => timestamp,
                                     :course => course
                                 },
                                 :translator => "FinalGradesTranslator"
                             })
    end
    notifications
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
