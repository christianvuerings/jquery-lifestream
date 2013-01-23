class CanvasUserActivityProxy < CanvasProxy

  def user_activity
    request("users/self/activity_stream", "_user_activity")
  end

end
