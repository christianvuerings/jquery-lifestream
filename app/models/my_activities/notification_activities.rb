# TODO collapse this class into app/models/notifications somewhere appropriate
module MyActivities
  class NotificationActivities
    include ActiveRecordHelper

    def self.translators
      @translators ||= {}
    end

    def self.append!(uid, activities)
      result = []
      use_pooled_connection {
        result = Notifications::Notification.where(:uid => uid, :occurred_at => Time.at(MyActivities::Merged.cutoff_date)..Time.now) || []
      }
      result.each do |notification|
        translator = (self.translators[notification.translator] ||= "Notifications::#{notification.translator}".constantize.new)
        event = translator.translate(notification)
        #basic validation before inserting into notifications array.
        if event.present? && event.kind_of?(Hash)
          activities << event
        end
      end
      activities
    end
  end
end
