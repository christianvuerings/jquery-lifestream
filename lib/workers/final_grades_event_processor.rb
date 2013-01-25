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
    Rails.logger.info "#{self.class.name} Found students enrolled in #{term_yr}-#{term_cd}-#{ccn}: #{students}"

    # TODO get real copy for title, summary, etc.
    # TODO look up course name in Oracle using CCN
    students.each do |student|
      uid = student["ldap_uid"]
      title = "Final grades have been entered for #{term_yr}-#{term_cd}-#{ccn}"
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
