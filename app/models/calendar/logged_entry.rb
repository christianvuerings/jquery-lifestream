module Calendar
  class LoggedEntry < ActiveRecord::Base

    self.table_name = 'class_calendar_log'

    attr_accessible :year, :term_cd, :ccn, :multi_entry_cd, :event_data, :event_id, :job_id,
                    :processed_at, :response_status, :response_body, :has_error

    def self.lookup(queued_entry)
      logged_entry = LoggedEntry.limit(1).order(job_id: :desc).where(
        "year = :year AND term_cd = :term_cd AND ccn = :ccn AND multi_entry_cd = :multi_entry_cd",
        {
          year: queued_entry.year,
          term_cd: queued_entry.term_cd,
          ccn: queued_entry.ccn,
          multi_entry_cd: queued_entry.multi_entry_cd
        })
      logged_entry[0]
    end

  end

end
