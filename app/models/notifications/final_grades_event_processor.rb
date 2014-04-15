module Notifications
  class FinalGradesEventProcessor < AbstractEventProcessor
    include ActiveRecordHelper

    def accept?(event)
      return false unless super event
      event["topic"] == "Bearfacts:EndOfTermGrades"
    end

    def process_internal(event, timestamp)
      return [] unless event["payload"] && courses = event["payload"]["course"]

      # The payload might not have packaged a single course as an array.
      courses = [courses] unless Array.try_convert(courses)

      notifications = {}
      courses.each do |course|
        next unless (ccn = course["ccn"]) && (course["term"]) && (year = course['term']["year"]) && (term = course['term']["name"])
        process_course(notifications, ccn, year, term, timestamp, event["topic"])
      end
      notifications.values
    end

    private
    def process_course(notifications, ccn, term_yr, term_cd, timestamp, topic)
      students = CampusOracle::Queries.get_enrolled_students(ccn, term_yr, term_cd)

      return [] unless students
      Rails.logger.debug "#{self.class.name} Found students enrolled in #{term_yr}-#{term_cd}-#{ccn}: #{students}"

      students.each do |student|
        event = {ccn: ccn, year: term_yr, term: term_cd, topic: topic}
        unless is_dupe?(student["ldap_uid"], event, timestamp, "FinalGradesTranslator")
          entry = nil
          use_pooled_connection {
            entry = Notifications::Notification.new(
              {
                :uid => student["ldap_uid"],
                :data => {
                  :event => event,
                  :timestamp => timestamp
                },
                :translator => "FinalGradesTranslator",
                :occurred_at => timestamp
              })
          }
          if entry.present?
            notifications["#{student["ldap_uid"]}#{ccn}#{term_yr}#{term_cd}"] ||= entry
          end
        end
      end
    end
  end
end
