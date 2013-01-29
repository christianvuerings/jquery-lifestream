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
    {:notifications => notifications}
  end

end
