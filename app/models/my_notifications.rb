require 'json'

class MyNotifications < MyMergedModel

  def get_feed_internal
    notifications = []
    translator = FinalGradesTranslator.new
    Notification.where(:uid => @uid).each do |notification|
      notifications.push translator.translate notification
    end
    {:notifications => notifications}
  end

end
