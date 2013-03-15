require 'json'

class MyActivities < MyMergedModel

  def self.translators
    @translators ||= {}
  end

  def get_feed_internal
    {
      :activities => get_canvas_activity.concat(get_notifications)
    }
  end

  private

  def get_canvas_activity
    canvas_activity_feed = CanvasUserActivityHandler.new(:user_id => @uid)
    canvas_results = canvas_activity_feed.get_feed_results
    canvas_results ||= []
  end

  def get_notifications
    result = []
    Notification.where(:uid => @uid).each do |notification|
      translator = (MyActivities.translators[notification.translator] ||= notification.translator.constantize.new)
      result.push translator.translate notification
    end
    result
  end

end
