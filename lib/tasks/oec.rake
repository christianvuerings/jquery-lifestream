namespace :oec do

  desc 'Export course_evaluations.csv file'
  task :course_evaluations => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    Oec::CourseEvaluations.new.export(timestamp)
    Rails.logger.warn "OEC CSV export completed. Timestamp: #{timestamp}"
  end

  desc 'Generate student files based on courses.csv input'
  task :students => :environment do
    timestamp = DateTime.now.strftime('%FT%T.%L%z')
    reader = Oec::FileReader.new("tmp/oec/courses.csv")
    [Oec::Students, Oec::CourseStudents].each do |klass|
      klass.new(reader.ccns, reader.gsi_ccns).export(timestamp)
    end
    Rails.logger.warn "OEC students export completed. Timestamp: #{timestamp}"
  end

end
