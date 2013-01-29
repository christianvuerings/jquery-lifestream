class FinalGradesTranslator

  def accept?(event)
    event["code"] == "EndOFTermGrade"
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

    course = data["course"]

    Rails.logger.info "#{self.class.name} translating: #{notification}; accept? #{accept?(event)}; timestamp = #{timestamp}; uid = #{uid}; course = #{course}"

    return false unless accept?(event) && (payload = event["payload"]) && timestamp && uid && course && course["course_title"]

    # TODO get real copy for title, summary, etc.
    title = "Final grades have been entered for #{course["course_title"]}"
    {
        :id => notification.id,
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
  end

end
