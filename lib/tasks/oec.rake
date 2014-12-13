namespace :oec do

  desc 'Export courses.csv file'
  task :courses => :environment do
    dept_set = Settings.oec.departments.to_set
    dept_set.each do |dept_name|
      Oec::Courses.new(dept_name).export
    end
    Oec::BiologyPostProcessor.new.post_process if dept_set.include? 'BIOLOGY'
    Rails.logger.warn "OEC course CSVs files created in directory: #{Oec::Export.new.export_directory}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    dept_set = Settings.oec.departments.to_set
    if dept_set.include? 'BIOLOGY'
      dept_set.add 'INTEGBI'
      dept_set.add 'MCELLBI'
    end
    export_dir = Oec::Export.new.export_directory
    dept_set.each do |dept_name|
      reader = Oec::FileReader.new("#{export_dir}/#{dept_name.gsub(/\s/, '_')}_courses.csv")
      [Oec::Students, Oec::CourseStudents].each do |klass|
        klass.new(reader.ccns, reader.gsi_ccns).export
      end
    end
    Rails.logger.warn "OEC student CSVs files created in directory: #{export_dir}"
  end

  desc 'Spreadsheet from dept compared against current campus data'
  task :diff => :environment do
    dept_name = ENV['dept_name']
    if dept_name.to_s == ''
      Rails.logger.warn 'Sample usage: rake oec:diff dept_name=BIOLOGY'
    else
      term = Settings.oec.current_terms_codes[0]
      file_path = "#{Settings.oec.export_home}/data/#{term.year}-#{term.code}/csv/work/#{dept_name.upcase}_courses.diff"
      Oec::SpreadsheetComparator.new(term, dept_name).write_diff_report file_path
      Rails.logger.warn "Diff summary: #{file_path}"
    end
  end

end
