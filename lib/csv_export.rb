class CsvExport

  def initialize(export_dir)
    @export_dir = export_dir
    unless File.exists? @export_dir
      FileUtils.mkdir_p @export_dir
    end
  end

  def output_filename(basename = "export", timestamp = DateTime.now.strftime('%F'))
    "#{@export_dir}/#{basename}-#{timestamp}.csv"
  end

  def export_directory
    @export_dir
  end

end
