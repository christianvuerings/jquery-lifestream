class AddEventIdToCalendarQueue < ActiveRecord::Migration

  def change
    add_column(:class_calendar_queue, :event_id, :string)
  end

end
