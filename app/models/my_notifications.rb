require 'json'

class MyNotifications < MyMergedModel

  def get_feed_internal
    {:notifications => Notification.where(:uid => @uid)}
  end

end
