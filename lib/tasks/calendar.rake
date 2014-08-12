namespace :calendar do

  desc 'Queues up calendar events based on student enrollments'
  task :preprocess => :environment do
    Rails.logger.warn 'Preprocessing student calendar entries'
    entries = Calendar::Preprocessor.new.get_entries
    entries.each do |entry|
      entry.save
    end
    Rails.logger.warn "Preprocessing done; #{entries.length} entries were saved."
  end

  desc 'Sends all queued calendar events to Google API'
  task :export => :environment do
    entries = Calendar::QueuedEntry.all
    Rails.logger.warn "Exporting #{entries.length} calendar entries to Google"
    exporter = Calendar::Exporter.new
    logged_entries = exporter.ship_entries entries
    Rails.logger.warn 'Export complete.'
  end

  desc 'USE WITH CAUTION: Queues up deletions of all events that have ever been created on Google.'
  task :queue_deletes_of_all_events => :environment do
    # retrieve every event ever created (that we know about).
    existing_entries = Calendar::LoggedEntry.where(transaction_type: Calendar::QueuedEntry::CREATE_TRANSACTION)

    # make a queue entry for each. The next run of calendar:export will actually remove them from Google.
    existing_entries.find_in_batches do |batch|
      batch.each do |entry|
        delete_entry = Calendar::QueuedEntry.new(
          {
            event_id: entry.event_id,
            year: entry.year,
            term_cd: entry.term_cd,
            ccn: entry.ccn,
            multi_entry_cd: entry.multi_entry_cd,
            transaction_type: Calendar::QueuedEntry::DELETE_TRANSACTION})
        delete_entry.save
      end
    end
  end

end
