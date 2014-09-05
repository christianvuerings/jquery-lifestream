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
      courses = Calendar::Queries.get_all_courses
      courses.each do |course|
        this_term_slug = Berkeley::TermCodes.to_slug(course['term_yr'], course['term_cd'])
        term = Berkeley::Terms.fetch.campus[this_term_slug]
        if term.blank?
          logger.error "Could not determine term #{this_term_slug} for course #{course['term_yr']}-#{course['term_cd']}-#{course['course_cntl_num']}"
          next
        end
        logger.info "Preprocessing #{course['course_name']} ccn = #{course['term_yr']}-#{course['term_cd']}-#{course['course_cntl_num']}, multi_entry_cd = #{course['multi_entry_cd']}, term = #{term.slug}"

        attendees = attendees(course['term_yr'], course['term_cd'], course['course_cntl_num'])
        schedule_translator = Calendar::ScheduleTranslator.new(course, term)
        rrule = schedule_translator.recurrence_rule
        class_time = schedule_translator.times
        if course['building_name'].present?
          building_translation = Berkeley::Buildings.get(course['building_name'])
          building = building_translation.present? ? building_translation['display'] : course['building_name']
          location = "#{strip_leading_zeros(course['room_number'])} #{building}, UC Berkeley"
        end

        entry = Calendar::QueuedEntry.where(
          year: course['term_yr'],
          term_cd: course['term_cd'],
          ccn: course['course_cntl_num'],
          multi_entry_cd: course['multi_entry_cd'].blank? ? '-' : course['multi_entry_cd']).first_or_initialize
        entry.transaction_type = Calendar::QueuedEntry::CREATE_TRANSACTION

        logged_entry = Calendar::LoggedEntry.lookup(entry)
        if logged_entry.present? && logged_entry.transaction_type != Calendar::QueuedEntry::DELETE_TRANSACTION
          # this event has already been recorded in Google. Should we consider deleting it?
          entry.event_id = logged_entry.event_id

          if attendees.empty?
            logger.info "Zero attendees, this will be a DELETE action"
            entry.transaction_type = Calendar::QueuedEntry::DELETE_TRANSACTION
          elsif rrule.blank?
            logger.info "Blank recurrence rule, this will be a DELETE action"
            entry.transaction_type = Calendar::QueuedEntry::DELETE_TRANSACTION
          else
            logger.info "This will be an UPDATE action"
            entry.transaction_type = Calendar::QueuedEntry::UPDATE_TRANSACTION
          end
        end

        if attendees.empty?
          # don't create events that have no attendees
          next unless entry.transaction_type == Calendar::QueuedEntry::DELETE_TRANSACTION
        end

        if class_time.blank? || rrule.blank?
          # don't attempt to create an event that is missing times
          logger.debug "Missing times and/or recurrence rule. Course dump: #{course.inspect}"
          next unless entry.transaction_type == Calendar::QueuedEntry::DELETE_TRANSACTION
        end

        event_data = {
          summary: course['course_name'],
          location: location,
          attendees: attendees,
          guestsCanSeeOtherGuests: false,
          guestsCanInviteOthers: false,
          locked: true,
          visibility: 'private'
        }
        if class_time.present? && rrule.present?
          event_data.merge!(
            {
              start: {
                dateTime: class_time[:start].rfc3339(3),
                timeZone: Time.zone.tzinfo.name
              },
              end: {
                dateTime: class_time[:end].rfc3339(3),
                timeZone: Time.zone.tzinfo.name
              },
              recurrence: [
                rrule
              ]
            })
        end
        entry.event_data = JSON.pretty_generate event_data
        entries << entry
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
 