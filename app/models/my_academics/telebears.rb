# TODO collapse this class into Bearfacts::Telebears
module MyAcademics
  class Telebears
    include AcademicsModule, ClassLogger, DatedFeed

    def merge(data)
      telebears_list = []
      telebears_terms.each do |term_id|
        if (parsed = parse_xml_feed(term_id))
          telebears_list.push(parsed)
        end
      end
      data[:telebears] = telebears_list
    end

    def parse_xml_feed(term_id)
      feed = Bearfacts::Telebears.new({user_id: @uid, term_id: term_id}).get[:feed]
      return if feed.blank?

      term = feed['telebearsAppointment']['termName'].to_text
      year = feed['telebearsAppointment']['termYear'].to_text.to_i
      return if term.blank? && year.zero?
      slug = "#{term.downcase}-#{year}"

      auth_release_code = feed['telebearsAppointment']['authReleaseCode'].to_text
      return if auth_release_code.blank?
      advisor_code_required = decode_advisor_code_required auth_release_code

      phases = parse_appointment_phases feed['telebearsAppointment']['telebearsAppointmentPhase'].to_a

      {
        term: term,
        year: year,
        slug: slug,
        advisorCodeRequired: advisor_code_required,
        phases: phases.compact,
        url: "http://registrar.berkeley.edu/tbfaqs.html"
      }
    end

    def include_current_term?
      all_terms = terms.campus.values
      if (ct_idx = all_terms.index{|t| t.sis_term_status == 'CT'})
        return DateTime.now.in_time_zone < all_terms[ct_idx].classes_start
      end
      false
    end

    def telebears_terms
      if include_current_term?
        ['CT', 'FT']
      else
        ['FT']
      end
    end

    private
    def parse_appointment_phases(phases)
      phases.map do |phase|
        # Dates come through in a fairly ugly format
        # <startDate>Monday    04/08/13 09:30 AM</startDate>
        startTime, endTime = %w(startDate endDate).map do |key|
          value = phase[key]
          next "" unless value.present?
          value.squish!
          # According to telebears, we're suppose to assume the time == our system time zone.
          # Forcing the timezone on the parsing causes DST translation problems.
          value = strptime_in_time_zone(value, "%A %m/%d/%y %I:%M %p")
          format_date(value)
        end

        period = phase['period']
        next unless period.present?
        {
          period: "#{period}",
          startTime: startTime,
          endTime: endTime,
        }
      end
    end

    def decode_advisor_code_required(code)
      default = {
        required: false,
        type: 'none'
      }

      case code
      when 'P'
        default
      when 'A'
        {
          required: true,
          type: 'advisor'
        }
      when 'C'
        {
          required: true,
          type: 'calso'
        }
      when 'N'
        {
          required: true,
          type: 'revoked'
        }
      else
        logger.warn "Unidentified advisor code value for UID #{@uid}: #{code}"
        default
      end
    end
  end
end
