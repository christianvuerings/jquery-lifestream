module Oec
  class Export < CsvExport

    def initialize(export_dir)
      super export_dir
    end

    def export(overwrite_file = true)
      file = output_filename
      output = CSV.open(
        file, overwrite_file ? 'wb' : 'a',
        {
          headers: headers,
          write_headers: overwrite_file
        }
      )
      append_records output
      output.close
      {
        filename: file
      }
    end

    def output_filename
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
