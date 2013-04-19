class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = BearfactsScheduleProxy.new({:user_id => @uid})
    feed = proxy.get

    #Bearfacts proxy will return nil on >= 400 errors.
    return {} if feed.nil?

    semesters = []
    schedule = []
    doc = Nokogiri::XML feed[:body]

    top_node = doc.css("studentClassSchedules")
    if top_node.nil? || top_node.empty?
      return {}
    end

    doc.css("classSchedule").each do |class_schedule|
      next unless to_text(class_schedule.css("instructnFormatDet")) == "LEC"
      course_number = "#{to_text(class_schedule.css("deptName"))} #{to_text(class_schedule.css("courseNumber"))}"
      next unless course_number.strip.length
      units = to_text(class_schedule.css("numberOfUnits"))
      title = to_text(class_schedule.css("courseTitle")).titleize
      grade_option = to_text(class_schedule.css("pnpFlag")).upcase == "Y" ? "P/NP" : "Letter"
      ccn = to_text(class_schedule.css("courseControlNumber"))
      format = to_text(class_schedule.css("instructnFormatDet"))
      section = "#{format} #{to_text(class_schedule.css("sectNum"))}"
      schedule_string = "#{to_text(class_schedule.css("weekGroup"))} #{to_time(class_schedule.css("startTime"))}#{to_text(class_schedule.css("startTimeAmPmFlag"))}-#{to_time(class_schedule.css("endTime"))}#{to_text(class_schedule.css("endTimeAmPmFlag"))}"
      instructor = to_text(class_schedule.css("instrShortName"))
      schedule << {
        :course_number => course_number,
        :ccn => ccn,
        :title => title,
        :units => units,
        :grade_option => grade_option,
        :section => section,
        :format => format,
        :schedule => schedule_string,
        :instructor => instructor
      }
    end

    semester_name = "#{top_node.attribute("termName").text} #{top_node.attribute("termYear").text}"
    semesters << {
      :name => semester_name,
      :slug => make_slug(semester_name),
      :is_current => true,
      :schedule => schedule
    }

    data[:semesters] = semesters
    data[:current_semester_index] = 0
  end
end
