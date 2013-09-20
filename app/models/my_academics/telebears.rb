class MyAcademics::Telebears
  include MyAcademics::AcademicsModule, ClassLogger, DatedFeed

  def merge(data)
    data[:telebears] = {}

    profile_feed = BearfactsTelebearsProxy.new({:user_id => @uid}).get
    return if profile_feed.nil?

    begin
      doc = Nokogiri::XML(profile_feed[:body], &:strict)
    rescue Nokogiri::XML::SyntaxError
      #Will only get here on >=400 errors, which are already logged
      return
    end

    term, year = %w(termName termYear).map { |key| doc.at_css("telebearsAppointment").attr(key) }
    year = Integer(year, 10) rescue nil

    return unless term.present? && year.present?

    adviser_code_required = decode_adviser_code_required(doc.at_css("telebearsAppointment authReleaseCode").text.strip)
    phases = parse_appointment_phases(doc.css("telebearsAppointment telebearsAppointmentPhase"))

    data[:telebears] = {
      term: term,
      year: year,
      adviser_code_required: adviser_code_required,
      phases: phases.compact,
      url: "http://registrar.berkeley.edu/tbfaqs.html"
    }
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
        value = value.squish.concat(" PST")
        value = DateTime.strptime(value, "%A %m/%d/%y %I:%M %p %Z")
        format_date(value)
      end
      next unless period.present?
      {
        period: "Tele-BEARS Phase #{period}",
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
        message: "At CalSO you need to get an adviser code. You need this code to get" \
          "into Tele-BEARS for your appointment"
      }
    else
      logger.warn "Unidentified adviser code value: #{code}"
      default
    end
  end
end