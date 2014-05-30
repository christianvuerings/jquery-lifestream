# TODO collapse this class into Bearfacts::Telebears
module MyAcademics
  class Telebears
    include AcademicsModule, ClassLogger, DatedFeed

    def merge(data)
      data[:telebears] = {}

      profile_feed = Bearfacts::Telebears.new({:user_id => @uid}).get
      return if profile_feed.nil?

      begin
        doc = Nokogiri::XML(profile_feed[:body], &:strict)
      rescue Nokogiri::XML::SyntaxError
        #Will only get here on >=400 errors, which are already logged
        return
      end

      return if doc.at_css("telebearsAppointment").nil?

      term, year = %w(termName termYear).map { |key| doc.at_css("telebearsAppointment").attr(key) }
      year = Integer(year, 10) rescue nil

      return unless term.present? && year.present?

      auth_release_code = doc.at_css("telebearsAppointment authReleaseCode").text.strip rescue return
      adviser_code_required = decode_adviser_code_required(auth_release_code)
      phases = parse_appointment_phases(doc.css("telebearsAppointment telebearsAppointmentPhase") || [])
      slug = "#{term.downcase}-#{year}"

      data[:telebears] = {
        term: term,
        year: year,
        slug: slug,
        adviser_code_required: adviser_code_required,
        phases: phases.compact,
        url: "http://registrar.berkeley.edu/tbfaqs.html"
      }

      # now make sure the semester of this Telebears appointment is represented in the feed, even if it has no classes.
      this_semester_in_feed = false
      data[:semesters] ||= []
      data[:semesters].each do |semester|
        if semester[:slug] == slug
          this_semester_in_feed = true
          break
        end
      end

      unless this_semester_in_feed
        data[:semesters].unshift(semester_info(year.to_s, Berkeley::TermCodes.to_code(term)))
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
          # According to telebears, we're suppose to assume the time == our system time zone (PST).
          # Forcing the timezone on the parsing causes DST translation problems.
          value = Time.strptime(value, "%A %m/%d/%y %I:%M %p").to_datetime
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
