# TODO collapse this class into Bearfacts::Exams
module MyAcademics
  class Exams
    include AcademicsModule
    include DatedFeed

    def merge(data = {})
      proxy = Bearfacts::Exams.new({:user_id => @uid})
      doc = proxy.get[:xml_doc]

      #Bearfacts proxy will return nil on >= 400 errors.
      return data unless doc.present? && matches_current_year_term?(doc.css("studentFinalExamSchedules"))
      exams = []

      doc.css("studentFinalExamSchedule").each do |exam|
        exam_data = exam.css("studentFinalExamScheduleKey")
        begin
          exam_datetime = Date.parse(to_text(exam_data.css("examDate"))).in_time_zone.to_datetime
        rescue ArgumentError => e
          # skip this exam if it has no parseable date
          Rails.logger.warn "#{self.class.name} Error parsing date in final exams feed for user #{@uid}: #{e.message}. Exam data is #{exam_data.to_s}"
          next
        end
        ampm = to_text(exam_data.css("startTimeAmPmFlag")) == 'A' ? 'AM' : 'PM'
        time = "#{to_time(exam_data.css("startTime"))} #{ampm}"
        raw_location = to_text exam.css("location")
        location = {
          :rawLocation => raw_location
        }
        location_data = Berkeley::Buildings.get(raw_location)
        unless location_data.nil?
          location = location.merge(location_data)
        end
        course_code = "#{to_text(exam_data.css("deptName"))} #{to_text(exam_data.css("coursePrefixNum"))}#{to_text(exam_data.css("courseRootNum"))}"
        exams << {
          :date => format_date(exam_datetime, "%a %B %-d"),
          :time => time,
          :location => location,
          :course_code => course_code
        }
      end
      exams.sort! { |a, b| a[:date][:epoch] <=> b[:date][:epoch] }
      data[:examSchedule] = exams
    end

    private

    def matches_current_year_term?(nodeset)
      begin
        term_year = nodeset.attribute("termYear").value.to_i
        term_code = nodeset.attribute("termCode").value
        return (current_term.code == term_code && current_term.year == term_year)
      rescue NoMethodError, ArgumentError => e
        Rails.logger.warn "#{self.class.name}: Error parsing studentFinalExamSchedules #{nodeset} for termYear and termCode - #{e.message}"
        return false
      end
    end
  end
end
