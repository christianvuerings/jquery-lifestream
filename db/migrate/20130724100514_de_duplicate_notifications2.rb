class DeDuplicateNotifications2 < ActiveRecord::Migration

  def up
    dupes = {}
    all_notifications = Notifications::Notification.all
    all_notifications.each do |n|
      start_date = n.occurred_at
      end_date = start_date.advance(:days => 1)
      possible_dupes = Notifications::Notification.where(:uid => n.uid, :translator => n.translator, :occurred_at => start_date...end_date)
      possible_dupes.each do |poss|
        if n.id != poss.id
          unless dupes[n.id]
            dupes[poss.id] = true
          end
        end
      end
    end
    Rails.logger.warn "Deleting the following notifications which are duplicates: #{dupes}"
    Notifications::Notification.delete(dupes.keys)
  end

  def down

  end
end
