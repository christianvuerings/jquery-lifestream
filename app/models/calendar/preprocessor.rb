module Calendar
  class Preprocessor

    include ClassLogger, SafeJsonParser

    def initialize
      @settings = Settings.class_calendar
      @users = Calendar::User.all
      @users_with_alternate_email = build_users_with_alternate_email
      logger.warn "#{@users.length} users are on the calendar whitelist"
    end

    def get_entries
      entries = []
      courses = Calendar::Queries.get_all_courses @users
      courses.each do |course|
        this_term_slug = Berkeley::TermCodes.to_slug(course['term_yr'], course['term_cd'])
        term = Berkeley::Terms.fetch.campus[this_term_slug]
        if term.blank?
          logger.error "Could not determine term #{this_term_slug} for course #{course['term_yr']}-#{course['term_cd']}-#{course['course_cntl_num']}"
          next
        end
        logger.info "Preprocessing #{course['course_name']} ccn = #{course['term_yr']}-#{course['term_cd']}-#{course['course_cntl_num']}, term = #{term.slug}"
        schedules = CampusOracle::Queries.get_section_schedules(course['term_yr'], course['term_cd'], course['course_cntl_num'])
        schedules.each do |sched|
          next unless sched.present?
          schedule_translator = Calendar::ScheduleTranslator.new(sched, term)
          rrule = schedule_translator.recurrence_rule
          class_time = schedule_translator.times
          next unless rrule.present?
          entry = Calendar::QueuedEntry.new
          entry.year = course['term_yr']
          entry.term_cd = course['term_cd']
          entry.ccn = course['course_cntl_num']
          entry.multi_entry_cd = sched['multi_entry_cd']
          location = "#{sched['building_name']} #{strip_leading_zeros(sched['room_number'])}"
          event_data = {
            summary: course['course_name'],
            location: location,
            start: {
              dateTime: class_time[:start].rfc3339(3),
              timeZone: Time.zone.tzinfo.name
            },
            end: {
              dateTime: class_time[:end].rfc3339(3),
              timeZone: Time.zone.tzinfo.name
            },
            attendees: attendees(course['term_yr'], course['term_cd'], course['course_cntl_num']),
            guestsCanSeeOtherGuests: false,
            guestsCanInviteOthers: false,
            locked: true,
            recurrence: [
              rrule
            ]
          }
          entry.event_data = JSON.pretty_generate event_data
          logger.debug "Event data for ccn #{course['term_yr']}-#{course['term_cd']}-#{course['course_cntl_num']}, multi_entry_cd = #{sched['multi_entry_cd']}: #{entry.event_data}"
          entries << entry
        end
      end
      entries
    end

    def attendees(term_yr, term_cd, ccn)
      # get list of attendee emails, from the official Oracle listing (calcentral_person_info_vw.alternateid)
      # or from the test override table in Postgres, class_calendar_users.alternate_email.
      emails = []
      enrollments = Calendar::Queries.get_whitelisted_students_in_course(@users, term_yr, term_cd, ccn)
      enrollments.each do |person|
        email = person['official_bmail_address']
        if @users_with_alternate_email[person['ldap_uid']].present?
          email = @users_with_alternate_email[person['ldap_uid']]
        end
        if email.present?
          emails << {
            email: email
          }
        end
      end
      emails
    end

    private

    def build_users_with_alternate_email
      results = {}
      @users.each do |user|
        if user.alternate_email.present?
          results[user.uid] = user.alternate_email
        end
      end
      results
    end

    def strip_leading_zeros(str=nil)
      (str.nil?) ? nil : "#{str}".gsub!(/^[0]*/, '')
    end

  end
end
 