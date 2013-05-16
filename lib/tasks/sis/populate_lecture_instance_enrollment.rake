namespace :sis do
  task :populate_lecture_instance_enrollment => :environment do |task_name|
    file = ENV["sections_file"] || ''
    dir = ENV["output_dir"] || ''

    file = File.expand_path file if file.present?
    if !File.exists?(file)
      Rails.logger.fatal "Rake:#{task_name}: Import sections_file does not exist. Aborting!"
      next
    end

    dir = File.expand_path dir unless dir.blank?
    if File.file?(dir)
      Rails.logger.fatal "Rake:#{task_name}: export_dir #{dir} must be a directory. Aborting!"
      next
    end
    FileUtils.mkdir_p dir
    begin
      generator = SIS::PopulateLectureInstanceEnrollment.new(file, dir)
      p generator.populate_section_enrollments
      generator.finalize
    rescue Exception => e
      Rails.logger.fatal "Unable to initialize processor: #{e}"
      next
    end

  end
end