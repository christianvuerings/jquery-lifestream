namespace :calendar do

  task :preprocess => :environment do
    Rails.logger.warn "Preprocessing student calendar entries"
    entries = Calendar::Preprocessor.new.get_entries
    entries.each do |entry|
      entry.save
      Rails.logger.debug "#{entry.inspect}"
    end
    Rails.logger.warn "Preprocessing done; #{entries.length} entries were saved."
  end

  task :export => :environment do
    entries = Calendar::QueuedEntry.all
    Rails.logger.warn "Exporting #{entries.length} calendar entries to Google"
    exporter = Calendar::Exporter.new
    logged_entries = exporter.ship_entries entries
    Rails.logger.warn "Export done; #{logged_entries.length} entries were shipped to Google."
  end
end
