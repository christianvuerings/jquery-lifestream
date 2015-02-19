module Oec
  class DeptConfirmedData

    attr_reader :confirmed_data_per_dept

    def initialize(src_dir, departments)
      @confirmed_data_per_dept = {}
      csv_filename_suffix = '_courses_confirmed.csv'
      pattern = "#{src_dir}/*#{csv_filename_suffix}"
      Rails.logger.debug "Find files matching #{pattern}"
      Dir[pattern].each do |filename|
        dept_name = filename.split('/')[-1].chomp(csv_filename_suffix).gsub(/_/, ' ').upcase
        Rails.logger.debug "Source directory contains #{filename} (owned by #{dept_name})"
        if departments.include? dept_name
          corrected_data = []
          CSV.read(filename).each_with_index do |row, index|
            corrected_data << Oec::RowConverter.new(row).hashed_row if index > 0 && row.length > 0
          end
          @confirmed_data_per_dept[dept_name] = corrected_data
          departments.delete dept_name
        end
      end
      Rails.logger.warn "Confirmed CSV file(s) NOT found for departments: #{departments.to_a}" if departments.length > 0
    end

  end
end
