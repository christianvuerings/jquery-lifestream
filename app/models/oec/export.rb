module Oec
  class Export < CsvExport

    def initialize
      term = Settings.oec.current_terms_codes[0]
      today = DateTime.now.strftime('%F')
      super "#{Settings.oec.export_home}/data/#{term.year}-#{term.code}/raw/#{today}"
    end

    def export
      output_filename = "#{export_directory}/#{base_file_name}.csv"
      output = CSV.open(
        output_filename, 'wb',
        {
          headers: headers,
          write_headers: true
        }
      )
      append_records output
      output.close
      {
        filename: output_filename
      }
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
