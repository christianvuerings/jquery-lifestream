namespace :oec do

  hr = "\n" + '-------------------------------------------------------------' + "\n"

  desc 'Export courses.csv file'
  task :courses => :environment do
    args = Oec::CommandLine.new
    Oec::CoursesGroup.new(Oec::DepartmentRegistry.new.to_a, args.dest_dir, true, args.is_debug_mode)
    Rails.logger.warn "#{hr}Find CSV files in directory: #{args.dest_dir}#{hr}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    args = Oec::CommandLine.new
    csv_file = "#{args.src_dir}/courses.csv"
    if File.exists? csv_file
      reader = Oec::FileReader.new csv_file
      [Oec::Students, Oec::CourseStudents].each do |klass|
        klass.new(reader.ccns, reader.gsi_ccns, args.dest_dir).export
      end
      Rails.logger.warn "#{hr}Find CSV files in directory: #{args.dest_dir}#{hr}"
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
    args = Oec::CommandLine.new
    # We generate CSV files from campus data to take advantage of post-processing logic.
    Rails.logger.warn "Generating CSV files for #{args.departments}"
    courses_group = Oec::CoursesGroup.new(args.departments)
    campus_data_per_dept = courses_group.campus_data_per_dept
    # Perform the diff op
    summaries = []
    confirmed_data_per_dept = Oec::DeptConfirmedData.new(args.src_dir, args.departments).confirmed_data_per_dept
    confirmed_data_per_dept.each do |dept_name, confirmed_data|
      Rails.logger.warn "CSV from #{dept_name} contains #{confirmed_data.length} records"
      courses_diff = Oec::CoursesDiff.new(dept_name, campus_data_per_dept[dept_name], confirmed_data, args.dest_dir)
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

end
