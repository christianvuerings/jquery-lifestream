module Oec
  class CsvExport < ::CsvExport

    def self.base_filename
      "#{self.name.demodulize.underscore}.csv"
    end

    def export(overwrite_file = true)
      file = output_filename
      output = CSV.open(file, 'wb')
      output << headers
      append_records output
      output.close
      {
        filename: file
      }
    end

    def output_filename
      export_directory.join self.class.base_filename
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
