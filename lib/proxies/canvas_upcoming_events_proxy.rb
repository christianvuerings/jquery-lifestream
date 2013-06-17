class CanvasUpcomingEventsProxy < CanvasProxy

  def upcoming_events
    request("users/self/upcoming_events?as_user_id=sis_user_id:#{@uid}", "_upcoming_events")
  end

end
