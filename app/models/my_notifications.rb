require 'json'

class MyNotifications < MyMergedModel

  def self.translators
    @translators ||= {}
  end

  def get_feed_internal
    notifications = []
    Notification.where(:uid => @uid).each do |notification|
      translator = (MyNotifications.translators[notification.translator] ||= notification.translator.constantize.new)
      notifications.push translator.translate notification
    end
    canvas_activity_feed = CanvasUserActivityHandler.new(:user_id => @uid)
    notifications.concat canvas_activity_feed.get_feed_results
    {:notifications => notifications}
  end

end
