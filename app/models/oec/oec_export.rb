class OecExport < CsvExport

  def initialize
    super(Settings.oec)
  end

  def export(timestamp = DateTime.now.strftime('%F'))
    output_filename = output_filename(base_file_name, timestamp)
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
    # subclasses override to define filename
  end

  def headers
    # subclasses override to define headers
  end

  def append_records(output_file)
    # subclasses override this to do work
  end

  def record_to_csv_row(record)
    row = {}
    record.keys.each do |key|
      row[key.upcase] = record[key]
    end
    row
  end

end
