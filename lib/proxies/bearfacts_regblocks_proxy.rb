class BearfactsRegblocksProxy < BearfactsProxy

  def get_blocks
    request("/student/#{@uid}/reg/regblocks", "regblocks")
  end

end
