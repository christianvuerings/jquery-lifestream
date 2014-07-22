module Calendar
  class Exporter

    include ClassLogger, SafeJsonParser

    def initialize
      @settings = Settings.class_calendar
      @insert_proxy = GoogleApps::EventsInsert.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @update_proxy = GoogleApps::EventsUpdate.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @get_proxy = GoogleApps::EventsGet.new(
        access_token: @settings.access_token,
        refresh_token: @settings.refresh_token,
        expiration_time: DateTime.now.to_i + 3599)
      @delete_proxy = GoogleApps::EventsDelete.new(
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

      queue_entries.each do |queue_entry|

        # figure out if we should attempt to delete or update an existing event
        if queue_entry.event_id.present?
          if queue_entry.transaction_type == Calendar::QueuedEntry::DELETE_TRANSACTION
            response = delete queue_entry
          else
            existing_attendees = []
            event_on_google = @get_proxy.get_event(queue_entry.event_id)
            if event_on_google.present?
              if event_on_google.body && (existing_json = safe_json(event_on_google.body))
                existing_attendees = existing_json['attendees']
              end
              response = update(queue_entry, existing_attendees)
            else
              # entry not found on Google, fall back to creating it
              queue_entry.transaction_type = Calendar::QueuedEntry::CREATE_TRANSACTION
            end
          end
        end

        if response.blank?
          response = insert queue_entry
        end

        if response.present?
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
        else
          logger.error "Got a nil response creating or updating event"
          @error_count += 1
          Calendar::LoggedEntry.create(
            {
              job_id: job.id,
              year: queue_entry.year,
              term_cd: queue_entry.term_cd,
              ccn: queue_entry.ccn,
              multi_entry_cd: queue_entry.multi_entry_cd,
              event_data: queue_entry.event_data,
              transaction_type: queue_entry.transaction_type,
              processed_at: DateTime.now,
              response_body: 'nil',
              has_error: true,
              event_id: queue_entry.event_id
            })
        end
      end

      job.total_entry_count = @total
      job.error_count = @error_count
      job.process_end_time = DateTime.now
      job.save
      logger.warn "Job #{job.id}: Export complete. Job total entry count: #{job.total_entry_count}; Error count: #{job.error_count}"
      true
    end

    def insert(queue_entry)
      logger.warn "Inserting event for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"
      begin
        response = @insert_proxy.insert_event(queue_entry.event_data)
      rescue StandardError => e
        logger.fatal "Google proxy error: #{e.inspect}"
      end
      response
    end

    def update(queue_entry, existing_attendees)
      logger.warn "Updating event #{queue_entry.event_id} for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"

      merge_attendee_responses(queue_entry, existing_attendees)

      begin
        response = @update_proxy.update_event(queue_entry.event_id, queue_entry.event_data)
      rescue StandardError => e
        logger.fatal "Google proxy error: #{e.inspect}"
      end
      response
    end

    def delete(queue_entry)
      logger.warn "Deleting event #{queue_entry.event_id} for ccn = #{queue_entry.year}-#{queue_entry.term_cd}-#{queue_entry.ccn}, multi_entry_cd = #{queue_entry.multi_entry_cd}"

      begin
        response = @delete_proxy.delete_event(queue_entry.event_id)
      rescue StandardError => e
        logger.fatal "Google proxy error: #{e.inspect}"
      end
      response
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
