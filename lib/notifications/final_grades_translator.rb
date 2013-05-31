class FinalGradesTranslator
  include DatedFeed

  def accept?(event)
    event["topic"] == "Bearfacts:EndOfTermGrades"
  end

  def translate(notification)
    data = notification.data
    uid = notification.uid
    event = data["event"]
    timestamp = notification.occurred_at.to_datetime

    Rails.logger.info "#{self.class.name} translating: #{notification}; accept? #{accept?(event)}; timestamp = #{timestamp}; uid = #{uid}"

    return false unless accept?(event) && timestamp && uid

    Rails.logger.debug "#{self.class.name} event = #{event}"
    course = CampusData.get_course_from_section(event["ccn"], event["year"], event["term"])

    return false unless course && course["dept_name"] && course["catalog_id"]

    title = "Final grades posted for #{course["dept_name"]} #{course["catalog_id"]}"
    {
        :id => notification.id,
        :title => title,
        :summary => "Your final grade is available in Bearfacts.",
        :source => event["system"],
        :type => "alert",
        :date => format_date(timestamp),
        :url => "https://bearfacts.berkeley.edu/bearfacts/",
        :source_url => "https://bearfacts.berkeley.edu/bearfacts/",
        :emitter => "Campus",
        :color_class => "campus-item"
    }
  end

end
