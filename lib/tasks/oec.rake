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
    src_dir = get_path_arg 'src'
    dest_dir = get_path_arg 'dest'
    summaries = []
    get_confirmed_csv_file_hash(src_dir).each do |dept_name, confirmed_csv_file|
      data_corrected_by_dept = []
      CSV.read(confirmed_csv_file).each_with_index do |row, index|
        data_corrected_by_dept << Oec::RowConverter.new(row).hashed_row if index > 0 && row.length > 0
      end
      Rails.logger.warn "CSV file #{confirmed_csv_file} contains #{data_corrected_by_dept.length} records"
      courses_diff = Oec::CoursesDiff.new(dept_name, data_corrected_by_dept, dest_dir)
      courses_diff.export
      if courses_diff.was_difference_found
        summaries << "#{dept_name}: #{courses_diff.output_filename}"
      else
        File.delete courses_diff.output_filename
        summaries << "#{dept_name}: Confirmed CSV matches campus data. No diff to report."
      end
    end
    if summaries.length > 0
      Rails.logger.warn "#{hr}#{summaries.join("\n")}#{hr}"
    else
      Rails.logger.warn "#{hr}Nonesuch 'confirmed' CSV files found in #{src_dir}#{hr}"
    end
  end

  private

  def get_confirmed_csv_file_hash(src_dir)
    confirmed_csv_file_hash = {}
    departments = ENV['departments'].to_s.strip.upcase.split(/\s*,\s*/).reject &:empty?
    csv_filename_suffix = '_courses_confirmed.csv'
    pattern = "#{src_dir}/*#{csv_filename_suffix}"
    Rails.logger.debug "Find files matching #{pattern}"
    Dir[pattern].each do |filename|
      dept_name = filename.split('/')[-1].chomp(csv_filename_suffix).gsub(/_/, ' ').upcase
      Rails.logger.debug "Source directory contains #{filename} (owned by #{dept_name})"
      if departments.empty? || departments.include?(dept_name)
        confirmed_csv_file_hash[dept_name] = filename
        departments.delete dept_name
      end
    end
    Rails.logger.warn "Confirmed CSV file(s) NOT found for departments: #{departments.to_a}" if departments.length > 0
    confirmed_csv_file_hash
  end

  def get_path_arg(arg_name)
    path = ENV[arg_name]
    return Rake.original_dir if path.blank?
    path.start_with?('/') ? path : File.expand_path(path, Rake.original_dir)
  end

end
