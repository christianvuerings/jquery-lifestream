class BearfactsScheduleProxy < BearfactsProxy

  def get_schedule
    request("/student/#{lookup_student_id}/reg/classschedule", "classschedule")
  end

end
