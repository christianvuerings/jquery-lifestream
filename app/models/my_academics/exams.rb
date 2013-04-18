class MyAcademics::Exams

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = BearfactsExamsProxy.new({:user_id => @uid})
    feed = proxy.get

    #Bearfacts proxy will return nil on >= 400 errors.
    return {} if feed.nil?

    dates = Hash.new
    doc = Nokogiri::XML feed[:body]
    doc.css("studentFinalExamSchedule").each do |exam|
      exam_data = exam.css("studentFinalExamScheduleKey")
      exam_datetime = DateTime.parse(to_text(exam_data.css("examDate")))
      exam_friendly_date = exam_datetime.strftime("%a %B %-d")
      time = "#{to_text(exam_data.css("startTime"))}#{to_text(exam_data.css("startTimeAmPmFlag"))}"
      location = to_text exam.css("location")
      course_number = "#{to_text(exam_data.css("deptName"))} #{to_text(exam_data.css("coursePrefixNum"))}#{to_text(exam_data.css("courseRootNum"))}"
      dates[exam_friendly_date] ||= []
      dates[exam_friendly_date] << {
        :time => time,
        :location => location,
        :course_number => course_number
      }
    end
    data[:exam_schedule] = dates
  end

end
