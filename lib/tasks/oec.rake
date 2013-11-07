namespace :oec do

  desc 'Export courses.csv file'
  task :courses => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    Courses.new.export(timestamp)
    Rails.logger.warn "OEC CSV export completed. Timestamp: #{timestamp}"
  end

  desc 'Generate instructor files based on courses.csv input'
  task :people => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    reader = CourseFileReader.new("tmp/oec/courses.csv")
    [Instructors, CourseInstructors].each do |klass|
      klass.new(reader.ccns).export(timestamp)
    end
    Rails.logger.warn "OEC instructors export completed. Timestamp: #{timestamp}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    reader = CourseFileReader.new("tmp/oec/courses.csv")
    [Students, CourseStudents].each do |klass|
      klass.new(reader.ccns, reader.gsi_ccns).export(timestamp)
    end
    Rails.logger.warn "OEC students export completed. Timestamp: #{timestamp}"
  end

end
