class FinalGradesTranslator

  def accept?(event)
    event["code"] == "EndOFTermGrade"
  end

  def translate(notification)
    event = notification["data"]["event"]
    timestamp = notification["data"]["timestamp"]
    uid = notification["data"]["uid"]
    course = notification["data"]["course"]

    return false unless accept?(event) && (payload = event["payload"]) && timestamp && uid && course && course["course_title"]
    Rails.logger.info "#{self.class.name} processing event: #{event}; timestamp = #{timestamp}; uid = #{uid}"

    # TODO get real copy for title, summary, etc.
    title = "Final grades have been entered for #{course["course_title"]}"
    {
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
  end

end
