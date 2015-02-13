module Oec
  class CoursesGroup

    attr_reader :campus_data_per_dept
    attr_reader :csv_per_dept
    attr_reader :dest_dir

    def initialize(departments, dest_dir = Dir.mktmpdir, keep_csv_files = false, debug_mode = false)
      @dest_dir = dest_dir
      @csv_per_dept = {}
      departments.each do |dept_name|
        courses = Oec::Courses.new(dept_name, dest_dir)
        courses.export
        @csv_per_dept[dept_name] = courses.output_filename
      end
      post_processor = Oec::BiologyPostProcessor.new(dest_dir, dest_dir, debug_mode)
      post_processor.post_process
      # Biology CSV file might be deleted by post-processor
      additional = post_processor.csv_per_dept
      biology = Oec::DepartmentRegistry.new.biology_dept_name
      @csv_per_dept.delete biology unless additional.include? biology
      @csv_per_dept.merge! additional
      @campus_data_per_dept = campus_data_per_dept keep_csv_files
    end

    def campus_data_per_dept(keep_csv_files)
      campus_data_per_dept = {}
      Oec::CoursesGroup.new(confirmed_data_per_dept.keys, @dest_dir).csv_per_dept.each do |dept_name, csv_file|
        campus_data = []
        CSV.read(csv_file).each_with_index do |row, index|
          campus_data << Oec::RowConverter.new(row).hashed_row if index > 0 && row.length > 0
        end
        campus_data_per_dept[dept_name] = campus_data
      end
      File.delete @dest_dir unless keep_csv_files
    end

  end
end
