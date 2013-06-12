namespace :canvas do

  desc 'Get all Canvas sections for current terms, make new CSV imports, refresh user accounts, and overwrite section memberships'
  task :full_refresh => :environment do
    canvas_worker = CanvasRefreshFromCampus.new
    canvas_worker.full_refresh
  end

  desc 'Get all Canvas sections for current terms and generate new CSV imports'
  task :make_csv_files => :environment do
    canvas_worker = CanvasRefreshFromCampus.new
    csv_files = canvas_worker.make_csv_files
    Rails.logger.info("Generated CSV files = #{csv_files.inspect}")
  end

  desc 'Repair Canvas Course SIS IDs (TERM_ID=x)'
  task :repair_sis_ids => :environment do
    term_id = ENV["TERM_ID"]
    if (term_id.blank?)
      Rails.logger.error("Must specify TERM_ID=YourSisTermId")
    else
      canvas_worker = CanvasRefreshFromCampus.new
      canvas_worker.repair_sis_ids_for_term(term_id)
    end
  end

end
