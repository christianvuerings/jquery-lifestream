module Oec
  class Export < CsvExport

    def initialize(export_dir)
      super export_dir
    end

    def export
      file = output_filename
      output = CSV.open(
        file, 'wb',
        {
          headers: headers,
          write_headers: true
        }
      )
      append_records output
      output.close
      {
        filename: file
      }
    end

    def output_filename(basename = nil, timestamp = nil)
      "#{export_directory}/#{base_file_name}.csv"
    end

    def base_file_name
      # subclasses override
    end

    def headers
      # subclasses override
    end

    def append_records(output_file)
      # subclasses override
    end

    def record_to_csv_row(record)
      row = {}
      record.keys.each do |key|
        row[key.upcase] = record[key]
      end
      row
    end

  end
end
