require 'json'

class MyNotifications < MyMergedModel

  def self.translators
    @translators ||= {}
  end

  def get_feed_internal
    canvas_activity_feed = CanvasUserActivityHandler.new(:user_id => @uid)
    canvas_results = canvas_activity_feed.get_feed_results
    canvas_results ||= []
    {:notifications => canvas_results}
  end

end
