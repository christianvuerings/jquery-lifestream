class BearfactsRegblocksProxy < BearfactsProxy

  def get
    request("/student/#{lookup_student_id}/reg/regblocks", "regblocks")
  end

end
