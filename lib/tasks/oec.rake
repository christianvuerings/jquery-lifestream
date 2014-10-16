namespace :oec do

  desc 'Export courses.csv file'
  task :courses => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    Settings.oec.departments.each do |dept_name|
      Oec::Courses.new(dept_name).export(timestamp)
    end
    Rails.logger.warn "OEC CSV export completed. Timestamp: #{timestamp}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    Settings.oec.departments.each do |dept_name|
      reader = Oec::FileReader.new("tmp/oec/#{dept_name.gsub(/\s/, '_')}_courses.csv")
      [Oec::Students, Oec::CourseStudents].each do |klass|
        klass.new(reader.ccns, reader.gsi_ccns).export(timestamp)
      end
      Rails.logger.warn "OEC students export completed. Timestamp: #{timestamp}"
    end
  end

end
