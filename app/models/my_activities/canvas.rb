class MyActivities::Canvas

  def self.append!(uid, activities)
    return unless CanvasProxy.access_granted?(uid)

    canvas_activity_feed = CanvasUserActivities.new(uid)
    canvas_results = canvas_activity_feed.get_feed
    activities.concat(canvas_results)
  end
end
