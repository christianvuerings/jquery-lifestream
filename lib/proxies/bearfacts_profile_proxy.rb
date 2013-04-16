class BearfactsProfileProxy < BearfactsProxy

  def get_profile
    request("/student/#{lookup_student_id}", "profile")
  end

end
