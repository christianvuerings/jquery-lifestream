module Calendar
  class Exporter

    include ClassLogger, SafeJsonParser

    def initialize
      @settings = Settings.class_calendar
      @insert_proxy = GoogleApps::EventsBatchInsert.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @update_proxy = GoogleApps::EventsBatchUpdate.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @get_proxy = GoogleApps::EventsBatchGet.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @delete_proxy = GoogleApps::EventsBatchDelete.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @error_count = 0
      @total = 0
    end

    def ship_entries(queue_entries=[])
      job = Calendar::Job.create
      job.process_start_time = DateTime.now
      logger.warn "Job #{job.id}: Preparing to ship #{queue_entries.length} entries to Google"
      @error_count = 0
      @total = 0

      # first queue up deletes and updates
      queue_entries.each do |queue_entry|
        if queue_entry.event_id.present?
          if queue_entry.transaction_type == Calendar::QueuedEntry::DELETE_TRANSACTION
            logger.warn "Deleting event #{queue_entry.event_id} for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"
            @delete_proxy.queue_event(queue_entry.event_id, Proc.new { |response|
              record_response(job, queue_entry, response)
            })
          else
            @get_proxy.queue_event(queue_entry.event_id, Proc.new { |response|
              if response.present? && response.status == 404
                # entry not found on Google, fall back to creating it
                queue_entry.transaction_type = Calendar::QueuedEntry::CREATE_TRANSACTION
              else
                existing_attendees = []
                if response.present? && response.body && (existing_json = safe_json(response.body))
                  existing_attendees = existing_json['attendees']
                end
                logger.warn "Updating event #{queue_entry.event_id} for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"
                merge_attendee_responses(queue_entry, existing_attendees)
                @update_proxy.queue_event(queue_entry.event_id, queue_entry.event_data, Proc.new { |update_response|
                  record_response(job, queue_entry, response)
                })
              end
            })
          end
        end
      end

      run_batch @delete_proxy
      run_batch @get_proxy
      run_batch @update_proxy

      # now queue up creates
      queue_entries.each do |queue_entry|
        if queue_entry.transaction_type == Calendar::QueuedEntry::CREATE_TRANSACTION
          @insert_proxy.queue_event(queue_entry.event_data, Proc.new { |response|
            logger.warn "Inserting event for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"
            record_response(job, queue_entry, response)
          })
        end
      end

      run_batch @insert_proxy

      job.total_entry_count = @total
      job.error_count = @error_count
      job.process_end_time = DateTime.now
      job.save
      logger.warn "Job #{job.id}: Export complete. Job total entry count: #{job.total_entry_count}; Error count: #{job.error_count}"
      true

    end

    def run_batch(proxy)
      begin
        proxy.run_batch
      rescue StandardError => e
        @error_count += 1
        logger.fatal "Google proxy error: #{e.inspect}"
      end
    end

    def record_response(job, queue_entry, response)
      event_id = queue_entry.event_id
      if event_id.blank? && response.body && (json = safe_json(response.body))
        event_id = json['id']
      end
      log_entry = Calendar::LoggedEntry.create(
        {
          job_id: job.id,
          year: queue_entry.year,
          term_cd: queue_entry.term_cd,
          ccn: queue_entry.ccn,
          multi_entry_cd: queue_entry.multi_entry_cd,
          event_data: queue_entry.event_data,
          transaction_type: queue_entry.transaction_type,
          processed_at: DateTime.now,
          response_status: response.status,
          response_body: response.body,
          has_error: response.status >= 400,
          event_id: event_id
        })
      @total += 1
      if log_entry.has_error
        @error_count += 1
      end
      queue_entry.delete
    end

    def merge_attendee_responses(queue_entry, existing_attendees)
      # if a user accepted or declined an event, that changes their 'attendees' array element on Google's servers.
      # we'll use the state of the attendees element on the Google side as our value for each attendee we're sending over.
      # if a user is on the Google list but not on our list, that means they've been dropped from the class, and we
      # don't need to do anything except post the new list of attendees without them.
      logger.debug "Existing attendees: #{existing_attendees.inspect}"
      new_data = safe_json(queue_entry.event_data)
      new_attendees = new_data['attendees']
      if existing_attendees.present? && new_attendees.present?
        hash_of_responses = {}
        existing_attendees.each do |attendee|
          hash_of_responses[attendee['email']] = attendee
        end
        new_attendees.each_with_index do |new_attendee, i|
          email = new_attendee['email']
          if hash_of_responses[email].present?
            new_attendees[i] = hash_of_responses[email]
          end
        end

        queue_entry.event_data = JSON.pretty_generate new_data
      end
    end

  end
end
