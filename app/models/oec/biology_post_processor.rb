module Oec
  class BiologyPostProcessor

    def initialize(export_dir)
      @export_dir = export_dir
    end

    def post_process
      header_row = nil
      biology_rows = []
      integbi_rows = []
      mcellbi_rows = []
      biology_dept_name = 'BIOLOGY'
      integbi_dept_name = 'INTEGBI'
      mcellbi_dept_name = 'MCELLBI'
      biology = Oec::Courses.new(biology_dept_name, @export_dir)
      CSV.read(biology.output_filename).each_with_index do | row, index |
        if index == 0
          header_row = row
        elsif row[1].match("#{biology_dept_name} 1A[L]?").present?
          row[4] = integbi_dept_name
          integbi_rows << row
        elsif row[1].match("#{biology_dept_name} 1B[L]?").present?
          row[4] = mcellbi_dept_name
          mcellbi_rows << row
        else
          biology_rows << row
        end
      end
      ExportWrapper.new(biology_dept_name, header_row, biology_rows, @export_dir, true).export
      ExportWrapper.new(integbi_dept_name, header_row, integbi_rows, @export_dir, false).export
      ExportWrapper.new(mcellbi_dept_name, header_row, mcellbi_rows, @export_dir, false).export
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
