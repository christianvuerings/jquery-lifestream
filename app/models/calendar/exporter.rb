module Calendar
  class Exporter

    include ClassLogger, SafeJsonParser

    def initialize
      @settings = Settings.class_calendar
    end

    def ship_entries(queue_entries=[])
      job = Calendar::Job.create
      job.process_start_time = DateTime.now
      logger.warn "class_calendar_jobs ID #{job.id}: Preparing to ship #{queue_entries.length} entries to Google"
      error_count = 0
      total = 0
      # TODO Handle update cases when event_id has already been recorded for this year-term-ccn combo.
      # TODO Use multi_entry_cd from schedule table as a PK when looking up logged entries to see if an insert or update is required.
      proxy = GoogleApps::EventsInsert.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      queue_entries.each do |queue_entry|
        begin
          response = proxy.insert_event(queue_entry.event_data)
        rescue StandardError => e
          error_count += 1
          logger.fatal "Google proxy error: #{e.inspect}"
        end

        if response.present?
          log_entry = Calendar::LoggedEntry.new
          log_entry.job_id = job.id
          log_entry.year = queue_entry.year
          log_entry.term_cd = queue_entry.term_cd
          log_entry.ccn = queue_entry.ccn
          log_entry.multi_entry_cd = queue_entry.multi_entry_cd
          log_entry.event_data = queue_entry.event_data
          log_entry.processed_at = DateTime.now
          log_entry.response_status = response.status
          log_entry.response_body = response.body
          log_entry.has_error = response.status >= 400
          if response.body && (json = safe_json(response.body))
            log_entry.event_id = json['id']
          end
          total += 1
          if log_entry.has_error
            error_count += 1
          end
          log_entry.save
          queue_entry.delete unless log_entry.has_error
        end
      end

      job.total_entry_count = total
      job.error_count = error_count
      job.process_end_time = DateTime.now
      job.save
      true
    end

  end
end
