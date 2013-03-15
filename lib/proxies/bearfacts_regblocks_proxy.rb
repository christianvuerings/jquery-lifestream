class BearfactsRegblocksProxy < BearfactsProxy

  def get_blocks
    request("/student/#{lookup_student_id}/reg/regblocks", "regblocks")
  end

end
