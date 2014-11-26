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
      doc = Bearfacts::Telebears.new({user_id: @uid, term_id: term_id}).get()[:xml_doc]
      return if doc.blank? || doc.at_css("telebearsAppointment").blank? ||
        doc.at_css("telebearsAppointment authReleaseCode").blank?

      term, year = %w(termName termYear).map { |key| doc.at_css("telebearsAppointment").attr(key) }
      year = Integer(year, 10) rescue nil

      return unless term.present? && year.present?

      auth_release_code = doc.at_css("telebearsAppointment authReleaseCode").text.strip rescue return
      adviser_code_required = decode_adviser_code_required(auth_release_code)
      phases = parse_appointment_phases(doc.css("telebearsAppointment telebearsAppointmentPhase") || [])
      slug = "#{term.downcase}-#{year}"

      {
        term: term,
        year: year,
        slug: slug,
        adviserCodeRequired: adviser_code_required,
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
        period = phase.css("period").text.strip
        # Dates come through in a fairly ugly format
        # <startDate>Monday    04/08/13 09:30 AM</startDate>
        startTime, endTime = %w(startDate endDate).map do |key|
          value = phase.css(key).text.strip
          next "" unless value.present?
          value.squish!
          # According to telebears, we're suppose to assume the time == our system time zone.
          # Forcing the timezone on the parsing causes DST translation problems.
          value = strptime_in_time_zone(value, "%A %m/%d/%y %I:%M %p")
          format_date(value)
        end
        next unless period.present?
        {
          period: "#{period}",
          startTime: startTime,
          endTime: endTime,
        }
      end
    end

    def decode_adviser_code_required(code)
      default = {
        required: false,
        message: "You do not need an adviser code for this semester"
      }

      case code
      when "P"
        default
      when "A"
        {
          required: true,
          message: "Before your Tele-BEARS appointment you need to get a code from your adviser"
        }
      when "C"
        {
          required: true,
          message: "At CalSO you need to get an adviser code. You need this code to get " \
            "into Tele-BEARS for your appointment"
        }
      else
        logger.warn "Unidentified adviser code value: #{code}"
        default
      end
    end
  end
end
