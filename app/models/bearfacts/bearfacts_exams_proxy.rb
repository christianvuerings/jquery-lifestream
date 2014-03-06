class BearfactsExamsProxy < BearfactsProxy

  def get
    request("/student/#{lookup_student_id}/reg/finalexams", "finalexams")
  end

end
