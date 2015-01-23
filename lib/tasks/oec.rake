namespace :oec do

  hr = "\n" + '-------------------------------------------------------------' + "\n"
  src_dir = ENV['src'].to_s == '' ? Dir.pwd : ENV['src']
  dest_dir = ENV['dest'].to_s == '' ? Dir.pwd : ENV['dest']

  desc 'Export courses.csv file'
  task :courses => :environment do
    dept_set = Settings.oec.departments.to_set
    dept_set.each do |dept_name|
      Oec::Courses.new(dept_name, dest_dir).export
    end
    Oec::BiologyPostProcessor.new(dest_dir).post_process if dept_set.include? 'BIOLOGY'
    Rails.logger.warn "#{hr}File(s) wrote to #{dest_dir}#{hr}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    dept_set = Settings.oec.departments.to_set
    if dept_set.include? 'BIOLOGY'
      dept_set.add 'INTEGBI'
      dept_set.add 'MCELLBI'
    end
    dept_set.each do |dept_name|
      filename = "#{dept_name.gsub(/\s/, '_')}_courses.csv"
      csv_file = "#{src_dir}/#{filename}"
      if File.exists? csv_file
        reader = Oec::FileReader.new csv_file
        [Oec::Students, Oec::CourseStudents].each do |klass|
          klass.new(reader.ccns, reader.gsi_ccns, dest_dir).export
        end
        Rails.logger.warn "#{hr}Files wrote to #{dest_dir}#{hr}"
      else
        Rails.logger.warn <<-eos
        #{hr}[ERROR] File not found: #{csv_file}
        Usage: rake oec:students [src=/path/to/source/] [dest=/export/path/]#{hr}
        eos
        raise ArgumentError, "Directory does not exist or is missing expected CSV file(s): #{src_dir}"
      end
    end
  end

  desc 'Spreadsheet from dept is compared with campus data'
  task :diff => :environment do
    dept_name = ENV['dept_name']
    if dept_name.to_s == ''
      Rails.logger.warn "#{hr}Usage: rake oec:diff dept_name=BIOLOGY [src=/path/to/files] [dest=/export/path/]#{hr}"
    else
      Oec::CoursesDiff.new(dept_name, src_dir, dest_dir).export
      Rails.logger.warn "#{hr}File wrote to #{dest_dir}#{hr}"
    end
  end

end
