class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = BearfactsScheduleProxy.new({:user_id => @uid})
    feed = proxy.get_schedule

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
      class_name = "#{to_text(class_schedule.css("deptName"))} #{to_text(class_schedule.css("courseNumber"))}"
      next unless class_name.strip.length
      units = to_text(class_schedule.css("numberOfUnits"))
      schedule << {
        :class_name => class_name,
        :units => units
      }
    end

    semester_name = "#{top_node.attribute("termName").text} #{top_node.attribute("termYear").text}"
    semesters << {
      :name => semester_name,
      :is_current => true,
      :schedule => schedule
    }

    data[:semesters] = semesters
    data[:current_semester_index] = 0
  end
end
