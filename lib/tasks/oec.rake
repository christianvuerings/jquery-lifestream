namespace :oec do

  desc 'Import per-department course CSVs, compare with dept spreadsheets and report on non-empty diffs.'
  task :import_courses => :environment do
    term_code = ENV['term_code']
    raise ArgumentError, 'term_code required' unless term_code
    [Oec::CoursesImportTask, Oec::ReportDiffTask].each do |klass|
      klass.new(
        term_code: term_code, local_write: ENV['local_write'],
        dept_names: ENV['dept_names'], dept_codes: ENV['dept_codes']).run
    end
  end

  desc 'Set up folder structure for new term'
  task :term_setup => :environment do
    raise ArgumentError, 'term_code required' unless ENV['term_code']
    task = Oec::TermSetupTask.new(
      term_code: ENV['term_code'], local_write: ENV['local_write'])
    task.run
  end

  # Legacy tasks below this line

  br = "\n"
  hr = "#{br}-------------------------------------------------------------#{br}"

  desc 'Export courses.csv file'
  task :courses => :environment do
    args = OecLegacy::CommandLine.new
    OecLegacy::CoursesGroup.new(OecLegacy::DepartmentRegistry.new.to_a, args.dest_dir, true, args.is_debug_mode)
    Rails.logger.warn "#{hr}Find CSV files in directory: #{args.dest_dir}#{hr}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    args = OecLegacy::CommandLine.new
    csv_file = "#{args.src_dir}/courses.csv"
    if File.exists? csv_file
      reader = OecLegacy::FileReader.new csv_file
      [OecLegacy::Students, OecLegacy::CourseStudents].each do |klass|
        klass.new(reader.ccn_set, reader.annotated_ccn_hash, args.dest_dir).export
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
    args = OecLegacy::CommandLine.new
    # Load CSVs edited by departments
    confirmed_data = OecLegacy::DeptConfirmedData.new(args.src_dir, args.departments)
    confirmed_csv_hash = confirmed_data.confirmed_data_per_dept
    messages_per_dept = confirmed_data.warnings_per_dept

    # Query campus data and post-process BIOLOGY, if necessary.
    Rails.logger.warn "Perform diff operation on confirmed CSVs provided by: #{confirmed_csv_hash.keys.to_a}"
    tmp_dir = "tmp/oec-#{DateTime.now.strftime('%s')}"
    debug_mode = args.is_debug_mode
    courses = OecLegacy::CoursesGroup.new(confirmed_csv_hash.keys, tmp_dir, debug_mode, debug_mode)
    # Do diff(s)
    confirmed_csv_hash.each do |dept_name, data_from_dept|
      campus_data = courses.campus_data_per_dept[dept_name]
      courses_diff = OecLegacy::CoursesDiff.new(dept_name, campus_data, data_from_dept, args.dest_dir, args.is_limited_diff)
      courses_diff.export
      diff_found = courses_diff.was_difference_found
      File.delete courses_diff.output_filename unless diff_found
      messages_per_dept[dept_name] ||= {}
      messages_per_dept[dept_name]['Diff report'] = diff_found ? "Created #{courses_diff.output_filename}" : 'No diff'
      messages_per_dept[dept_name].merge! courses_diff.errors_per_course_id if courses_diff.errors_per_course_id.any?
    end
    # Summarize for the user
    summary = "#{hr}Summary#{br}"
    summary << "No files found in #{args.src_dir}" if confirmed_csv_hash.empty?
    summary << 'Diff is limited to CSV rows where evaluate=Y' if args.is_limited_diff
    messages_per_dept.each do |dept_name, message_hash|
      summary << "  #{dept_name}#{br}"
      indent_each = '      '
      message_hash.each do |header, messages|
        summary << "    #{header}#{br}"
        if messages.is_a? Array
          summary << indent_each + messages.join("#{br}#{indent_each}") + br
        else
          summary << "#{indent_each}#{messages.to_s}#{br}"
        end
      end
    end
    Rails.logger.warn "#{summary}#{hr}" unless summary.blank?
  end

end
