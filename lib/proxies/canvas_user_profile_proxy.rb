class CanvasUserProfileProxy < CanvasProxy

  def user_profile
    request("users/sis_login_id:#{@uid}/profile", "_user_profile")
  end

  def log_error(fetch_options, response)
    # 404 for this proxy just means the user doesn't have a Canvas profile, so don't bother logging.
    if response.status == 404
      logger.debug "User does not have a Canvas account: UID #{@uid}: #{response.status} #{response.body}"
    else
      super
    end
  end
end
