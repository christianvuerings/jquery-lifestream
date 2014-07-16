module Calendar
  class QueuedEntry < ActiveRecord::Base

    CREATE_TRANSACTION = 'C'
    UPDATE_TRANSACTION = 'U'
    DELETE_TRANSACTION = 'D'

    self.table_name = 'class_calendar_queue'

    attr_accessible :year, :term_cd, :ccn, :multi_entry_cd, :event_data, :event_id, :transaction_type

  end

end
