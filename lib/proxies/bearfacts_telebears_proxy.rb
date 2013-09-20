class BearfactsTelebearsProxy < BearfactsProxy

  def get
    request("/student/#{lookup_student_id}/reg/appointments", "telebears")
  end

end
