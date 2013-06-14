class CanvasUserActivityProxy < CanvasProxy

  def user_activity
    request("users/self/activity_stream?as_user_id=sis_user_id:#{@uid}", "_user_activity")
  end

end
