namespace :oec do

  hr = "\n" + '-------------------------------------------------------------' + "\n"

  desc 'Export courses.csv file'
  task :courses => :environment do
    dest_dir = get_path_arg 'dest'
    files_created = []
    Oec::DepartmentRegistry.new.each do |dept_name|
      exporter = Oec::Courses.new(dept_name, dest_dir)
      exporter.export
      files_created << "#{dest_dir}/#{exporter.base_file_name}.csv"
    end
    debug_mode = ENV['debug'].to_s =~ /true/i
    post_processor = Oec::BiologyPostProcessor.new(dest_dir, dest_dir, debug_mode)
    post_processor.post_process
    Rails.logger.warn "#{hr}Find CSV files in directory: #{dest_dir}#{hr}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    src_dir = get_path_arg 'src'
    dest_dir = get_path_arg 'dest'
    csv_file = "#{src_dir}/courses.csv"
    if File.exists? csv_file
      reader = Oec::FileReader.new csv_file
      [Oec::Students, Oec::CourseStudents].each do |klass|
        klass.new(reader.ccns, reader.gsi_ccns, dest_dir).export
      end
      Rails.logger.warn "#{hr}Find CSV files in directory: #{dest_dir}#{hr}"
    else
      Rails.logger.warn <<-eos
      #{hr}File not found: #{csv_file}
      Usage: rake oec:students [src=/path/to/source/] [dest=/export/path/]#{hr}
      eos
      raise ArgumentError, "File not found: #{csv_file}"
    end
  end

  desc 'Spreadsheet from dept is compared with campus data'
  task :diff => :environment do
    dept_name = ENV['dept_name']
    if dept_name.blank?
      Rails.logger.warn "#{hr}Usage: rake oec:diff dept_name=BIOLOGY [src=/path/to/files] [dest=/export/path/]#{hr}"
    else
      src_dir = get_path_arg 'src'
      dest_dir = get_path_arg 'dest'
      courses_diff = Oec::CoursesDiff.new(dept_name.upcase.gsub(/_/, ' '), src_dir, dest_dir)
      courses_diff.export
      if courses_diff.was_difference_found
        Rails.logger.warn "#{hr}Find summary in #{courses_diff.output_filename}#{hr}"
      else
        File.delete courses_diff.output_filename
        Rails.logger.warn "#{hr}No diff found in #{dept_name} csv.#{hr}"
      end
    end
  end

  private

  def get_path_arg(arg_name)
    path = ENV[arg_name]
    return Rake.original_dir if path.blank?
    path.start_with?('/') ? path : File.expand_path(path, Rake.original_dir)
  end

end
