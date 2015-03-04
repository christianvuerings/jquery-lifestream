module Oec
  class DeptConfirmedData

    attr_reader :confirmed_data_per_dept
    attr_reader :warnings_per_dept

    def initialize(src_dir, departments)
      @confirmed_data_per_dept = {}
      @warnings_per_dept = {}
      csv_filename_suffix = '_courses_confirmed.csv'
      pattern = "#{src_dir}/*#{csv_filename_suffix}"
      csv_file_hash = {}
      Dir[pattern].each do |filename|
        dept_name = filename.split('/')[-1].chomp(csv_filename_suffix).gsub(/_/, ' ').upcase
        csv_file_hash[dept_name] = filename
      end
      (departments.empty? ? Settings.oec.departments : departments).each do |dept_name|
        if csv_file_hash.has_key? dept_name
          corrected_data = []
          filename = csv_file_hash[dept_name]
          CSV.read(filename).each_with_index do |row, index|
            if row.empty? || row[0].blank?
              put_warning(dept_name, "#{dept_name}#{csv_filename_suffix} has corrupt or missing data at row #{index + 1}")
            elsif index > 0
              corrected_data << Oec::RowConverter.new(row).hashed_row
            end
          end
          @confirmed_data_per_dept[dept_name] = corrected_data
        elsif !departments.empty?
          put_warning(dept_name, "The file #{dept_name}#{csv_filename_suffix} was not found in #{src_dir}")
        end
      end
    end

    def put_warning(dept_name, message)
      @warnings_per_dept[dept_name] ||= []
      @warnings_per_dept[dept_name] << message
    end

  end
end
