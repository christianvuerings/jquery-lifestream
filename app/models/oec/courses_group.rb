module Oec
  class CoursesGroup

    attr_reader :campus_data_per_dept
    attr_reader :csv_per_dept
    attr_reader :dest_dir

    def initialize(departments, dest_dir, keep_csv_files = false, debug_mode = false)
      @dest_dir = dest_dir
      @csv_per_dept = {}
      registry = Oec::DepartmentRegistry.new departments
      registry.each do |dept_name|
        courses = Oec::Courses.new(dept_name, dest_dir)
        courses.export
        @csv_per_dept[dept_name] = courses.output_filename
      end
      biology = registry.biology_dept_name
      if registry.include? biology
        Rails.logger.info 'Running biology post-processor logic.'
        post_processor = Oec::BiologyPostProcessor.new(dest_dir, dest_dir, debug_mode)
        post_processor.post_process
        # Biology CSV file might be deleted by post-processor
        additional = post_processor.csv_per_dept
        @csv_per_dept.delete biology unless additional.include? biology
        @csv_per_dept.merge! additional
      end
      @campus_data_per_dept = {}
      @csv_per_dept.each do |dept_name, csv_file|
        campus_data = []
        CSV.read(csv_file).each_with_index do |row, index|
          campus_data << Oec::RowConverter.new(row).hashed_row if index > 0 && row.length > 0
        end
        File.delete csv_file unless keep_csv_files
        @campus_data_per_dept[dept_name] = campus_data
      end
      Dir.delete @dest_dir unless keep_csv_files
    end

  end
end
