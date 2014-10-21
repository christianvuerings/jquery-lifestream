module Oec
  class CoursesWrapper

    def create_csv_file_per_dept
      timestamp = DateTime.now.strftime '%FT%T.%L%z'
      Settings.oec.departments.each do |dept_name|
        Oec::Courses.new(dept_name).export timestamp
      end
      post_process_biology timestamp
      Rails.logger.warn "OEC CSV export completed. Timestamp: #{timestamp}"
      timestamp
    end

    def post_process_biology(timestamp)
      header_row = nil
      biology_rows = []
      integbi_rows = []
      mcellbi_rows = []
      biology_dept_name = 'BIOLOGY'
      integbi_dept_name = 'INTEGBI'
      mcellbi_dept_name = 'MCELLBI'
      biology = Oec::Courses.new biology_dept_name
      filename = biology.output_filename(biology.base_file_name, timestamp)
      CSV.read(filename).each_with_index do | row, index |
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
      ExportWrapper.new(biology_dept_name, header_row, biology_rows, true).export timestamp
      ExportWrapper.new(integbi_dept_name, header_row, integbi_rows, false).export timestamp
      ExportWrapper.new(mcellbi_dept_name, header_row, mcellbi_rows, false).export timestamp
    end

  end

  class ExportWrapper < Oec::Courses

    def initialize(dept_name, header_row, rows, overwrite_file = false)
      super dept_name
      @header_row = header_row
      @rows = rows
      @overwrite_file = overwrite_file
    end

    def export(timestamp = nil)
      output_filename = output_filename(base_file_name, timestamp)
      output = CSV.open(
        output_filename, @overwrite_file ? 'wb' : 'a',
        {
          headers: headers,
          write_headers: @overwrite_file
        }
      )
      append_records output
      output.close
      {
        filename: output_filename
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
