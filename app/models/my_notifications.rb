require 'json'

class MyNotifications < MyMergedModel

  def get_feed_internal(opts={})
    data = JSON.parse(File.read(Rails.root.join('public/dummy/json/notifications.json')))
    data
  end

end