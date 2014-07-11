module Calendar
  class LoggedEntry < ActiveRecord::Base

    self.table_name = 'class_calendar_log'

    attr_accessible :year, :term_cd, :ccn, :multi_entry_cd, :event_data, :event_id, :job_id,
                    :processed_at, :response_status, :response_body, :has_error

  end

end
