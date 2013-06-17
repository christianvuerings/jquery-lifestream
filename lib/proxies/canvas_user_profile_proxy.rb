class CanvasUserProfileProxy < CanvasProxy

  def user_profile
    request("users/sis_user_id:#{@uid}/profile", "_user_profile")
  end

end
