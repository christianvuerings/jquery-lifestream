module Oec
  class Export < CsvExport

    def initialize
      settings = Object.new
      def settings.export_directory
        term = Settings.oec.current_terms_codes[0]
        today = DateTime.now.strftime('%F')
        "#{Settings.oec.export_home}/data/#{term.year}-#{term.code}/raw/#{today}"
      end
      super settings
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
