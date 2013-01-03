class CanvasComingUpProxy < CanvasProxy

  def coming_up
    request("users/self/coming_up", "_coming_up")
  end

end
