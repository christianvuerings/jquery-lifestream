class CanvasUserProfileProxy < CanvasProxy
  def initialize(options = {})
    options[:admin] = true
    super(options)
  end

  def user_profile
    request("users/sis_user_id:#{@uid}/profile", "_user_profile")
  end

end
