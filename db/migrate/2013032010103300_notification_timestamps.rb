class NotificationTimestamps < ActiveRecord::Migration

  def up
    add_column "notifications", :occurred_at, :datetime

    Notifications::Notification.find_each do |notification|
      begin
        timestamp = Time.parse(notification.data["timestamp"]).to_datetime
      rescue
        timestamp = notification.created_at
      end
      Rails.logger.info "Notification #{notification.id} for #{notification.uid} occurred at #{timestamp}, updating"
      notification.occurred_at = timestamp
      notification.save
    end

    add_index "notifications", ["occurred_at"], :name => "index_notifications_on_occurred_at"

  end

  def down
    remove_column "notifications", :occurred_at
  end

end
