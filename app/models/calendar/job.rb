module Calendar
  class Job < ActiveRecord::Base

    self.table_name = 'class_calendar_jobs'

    attr_accessible :process_start_time, :process_end_time, :total_entry_count, :error_count

  end
end
