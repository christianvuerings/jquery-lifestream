module Oec
  class BiologyPostProcessor

    def initialize(export_dir)
      @export_dir = export_dir
    end

    def post_process
      biology_dept = 'BIOLOGY'
      biology = Oec::Courses.new(biology_dept, @export_dir)
      path_to_biology_csv = biology.output_filename
      if File.exist? path_to_biology_csv
        header_row = nil
        integbi_dept = 'INTEGBI'
        mcellbi_dept = 'MCELLBI'
        sorted_dept_rows = {}
        CSV.read(path_to_biology_csv).each_with_index do | row, index |
          dept_name = row[4]
          course_name = row[1]
          if index == 0
            header_row = row
          elsif dept_name.include?(mcellbi_dept) || dept_name.include?(integbi_dept)
            Rails.logger.warn "#{row[0]} #{row[1]} #{biology.base_file_name} skipped. Course is listed #{dept_name} CSV file."
          else
            target_csv = biology_dept
            if course_name.match(' 1A[L]?').present?
              target_csv = row[4] = mcellbi_dept
            elsif course_name.match(' 1B[L]?').present?
              target_csv = row[4] = integbi_dept
            end
            sorted_dept_rows[target_csv] ||= []
            sorted_dept_rows[target_csv] << row
          end
        end
        File.delete path_to_biology_csv
        export_rules = { biology_dept => true, integbi_dept => false, mcellbi_dept => false }
        export_rules.each do | next_dept_name, overwrite_file |
          rows = sorted_dept_rows[next_dept_name]
          if rows && rows.length > 0
            ExportWrapper.new(next_dept_name, header_row, rows, @export_dir).export overwrite_file
          end
        end
      end
    end
  end

  class ExportWrapper < Oec::Courses

    def initialize(dept_name, header_row, rows, export_dir)
      super(dept_name, export_dir)
      @header_row = header_row
      @rows = rows
    end

    def headers
      @header_row
    end

    def append_records(output)
      @rows.each do |row|
        output << row
      end
    end

  end
end
