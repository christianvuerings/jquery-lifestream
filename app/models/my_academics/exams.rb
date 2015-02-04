# TODO collapse this class into Bearfacts::Exams
module MyAcademics
  class Exams
    include AcademicsModule
    include ClassLogger
    include DatedFeed

    def merge(data = {})
      proxy = Bearfacts::Exams.new({:user_id => @uid})
      feed = proxy.get[:feed]
      return unless feed.present? && matches_current_year_term?(feed)

      exams = []

      feed['studentFinalExamSchedules']['studentFinalExamSchedule'].as_collection.each do |exam|
        exam_data = exam['studentFinalExamScheduleKey']

        exam_datetime = exam_data['examDate'].to_date
        if exam_datetime.blank?
          logger.warn "Error parsing date in final exams feed for user #{@uid}, exam data: #{exam_data.unwrap}"
          next
        end

        ampm = exam_data['startTimeAmPmFlag'].to_text == 'A' ? 'AM' : 'PM'
        time = "#{exam_data['startTime'].to_time} #{ampm}"

        raw_locations = exam['studentFinalExamLocation'].as_collection.inject([]) { |arr, loc| arr.concat loc['location'].to_a  }
        locations = raw_locations.map do |raw_location|
          location_data = Berkeley::Buildings.get(raw_location) || {}
          {raw: raw_location}.merge(location_data)
        end

        course_code = "#{exam_data['deptName'].to_text} #{exam_data['coursePrefixNum'].to_text}#{exam_data['courseRootNum'].to_text}"

        exams << {
          date: format_date(exam_datetime, '%a %B %-d'),
          time: time,
          locations: locations,
          course_code: course_code
        }
      end

      data[:examSchedule] = exams.sort { |a, b| a[:date][:epoch] <=> b[:date][:epoch] }
    end

    private

    def matches_current_year_term?(feed)
      term_year = feed['studentFinalExamSchedules']['termYear'].to_text
      term_code = feed['studentFinalExamSchedules']['termCode'].to_text
      if term_year.blank? || term_code.blank?
        logger.warn "Error parsing termYear and termCode from feed: #{feed.unwrap}"
      end
      current_term.code == term_code && current_term.year == term_year.to_i
    end

  end
end
