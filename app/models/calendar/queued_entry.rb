module Calendar
  class QueuedEntry < ActiveRecord::Base

    self.table_name = 'class_calendar_queue'

    attr_accessible :year, :term_cd, :ccn, :multi_entry_cd, :event_data, :event_id

  end

end
