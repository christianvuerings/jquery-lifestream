module Oec
  class BiologyPostProcessor

    def initialize(export_dir)
      @export_dir = export_dir
    end

    def post_process
      biology_dept_name = 'BIOLOGY'
      biology = Oec::Courses.new(biology_dept_name, @export_dir)
      path_to_biology_csv = biology.output_filename
      if File.exist? path_to_biology_csv
        header_row = nil
        biology_rows = []
        integbi_rows = []
        mcellbi_rows = []
        integbi_dept_name = 'INTEGBI'
        mcellbi_dept_name = 'MCELLBI'
        CSV.read(path_to_biology_csv).each_with_index do | row, index |
          dept_name = row[4]
          course_name = row[1]
          if index == 0
            header_row = row
          elsif course_name.match("#{biology_dept_name} 1A[L]?").present? || dept_name.include?('INTEGBI')
            row[4] = integbi_dept_name
            integbi_rows << row
          elsif course_name.match("#{biology_dept_name} 1B[L]?").present? || dept_name.include?('MCELLBI')
            row[4] = mcellbi_dept_name
            mcellbi_rows << row
          else
            biology_rows << row
          end
        end
        File.delete path_to_biology_csv
        ExportWrapper.new(biology_dept_name, header_row, biology_rows, @export_dir, true).export if biology_rows.length > 0
        ExportWrapper.new(integbi_dept_name, header_row, integbi_rows, @export_dir, false).export if integbi_rows.length > 0
        ExportWrapper.new(mcellbi_dept_name, header_row, mcellbi_rows, @export_dir, false).export if mcellbi_rows.length > 0
      end
    end
  end

  class ExportWrapper < Oec::Courses

    def initialize(dept_name, header_row, rows, export_dir, overwrite_file = false)
      super(dept_name, export_dir)
      @header_row = header_row
      @rows = rows
      @overwrite_file = overwrite_file
    end

    def export
      file = output_filename
      output = CSV.open(
        file, @overwrite_file ? 'wb' : 'a',
        {
          headers: headers,
          write_headers: @overwrite_file
        }
      )
      append_records output
      output.close
      {
        filename: file
      }
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
