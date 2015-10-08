module Oec
  class Task
    extend Cache::Cacheable
    include ClassLogger

    LOG_DIRECTORY = Pathname.new Settings.oec.local_write_directory

    class << self; attr_accessor :success_callback; end

    def self.on_success_run(task_class, opts={})
      self.success_callback = opts.merge(class: task_class)
    end

    def self.date_format
      '%F'
    end

    def self.cache_key(id)
      "Oec::Task/#{id}"
    end

    def self.timestamp_format
      '%H:%M:%S'
    end

    def initialize(opts)
      @opts = opts
      @log = []
      @status = 'In progress'
      @api_task_id = opts[:api_task_id]
      write_status_to_cache if opts[:log_to_cache]

      @remote_drive = Oec::RemoteDrive.new
      @term_code = opts[:term_code]
      @date_time = opts[:date_time] || default_date_time
      @course_code_filter = if opts[:dept_names]
                             {dept_name: opts[:dept_names].split.map { |name| name.tr('_', ' ') }}
                           elsif opts[:dept_codes]
                             {dept_code: opts[:dept_codes].split}
                           else
                             {dept_name: Oec::CourseCode.included_dept_names}
                           end
    end

    def run
      log :info, "Starting #{self.class.name}"
      run_internal
      @status = 'Success' unless self.class.success_callback
      true
    rescue => e
      log :error, "#{self.class.name} aborted with error: #{e.message}\n#{e.backtrace.join "\n\t"}"
      @status = 'Error'
      nil
    ensure
      write_log
      write_status_to_cache if @opts[:log_to_cache]
      run_success_callback if self.class.success_callback && @status != 'Error'
    end

    private

    def default_date_time
      DateTime.now
    end

    def copy_file(file, dest_folder)
      return if @opts[:local_write]
      @remote_drive.check_conflicts_and_copy_file(file, dest_folder,
        on_success: -> { log :debug, "Copied file '#{file.title}' to remote drive folder '#{dest_folder.title}'" }
      )
    end

    def create_folder(folder_name, parent=nil)
      return if @opts[:local_write]
      @remote_drive.check_conflicts_and_create_folder(folder_name, parent,
        on_conflict: :error,
        on_creation: -> { log :debug, "Created remote folder '#{folder_name}'" }
      )
    end

    def datestamp(arg = @date_time)
      arg.strftime self.class.date_format
    end

    def default_term_dates
      if (course_overrides_sheet = get_overrides_worksheet Oec::Courses)
        default_term_dates_row = course_overrides_sheet.find do |row|
          row['DEPT_NAME'].blank? &&
            row['CATALOG_ID'].blank? &&
            row['INSTRUCTION_FORMAT'].blank? &&
            row['SECTION_NUM'].blank? &&
            row['START_DATE'].present? &&
            row['END_DATE'].present?
        end
        default_term_dates_row.slice('START_DATE', 'END_DATE') if default_term_dates_row
      end
    end

    def export_sheet(worksheet, dest_folder)
      if @opts[:local_write]
        worksheet.write_csv
        log :debug, "Exported worksheet to local file #{worksheet.csv_export_path}"
      else
        upload_worksheet(worksheet, worksheet.export_name, dest_folder)
      end
    end

    def export_sheet_headers(klass, dest_folder)
      worksheet = klass.new
      if @opts[:local_write]
        worksheet.write_csv
        log :debug, "Exported to header-only local file #{worksheet.csv_export_path}"
      else
        @remote_drive.check_conflicts_and_upload(worksheet, klass.export_name, Oec::Worksheet, dest_folder,
          on_success: -> { log :debug, "Uploaded header-only sheet '#{klass.export_name}' to remote drive folder '#{dest_folder.title}'" })
      end
    end

    def find_or_create_folder(folder_name, parent=nil)
      @remote_drive.check_conflicts_and_create_folder(folder_name, parent,
        on_conflict: :return_existing,
        on_creation: -> { log :debug, "Created remote folder '#{folder_name}'" }
      )
    end

    def find_or_create_now_subfolder(category_name)
      return if @opts[:local_write]
      parent = @remote_drive.find_nested([@term_code, category_name], on_failure: :error)
      find_or_create_folder("#{datestamp} #{timestamp}", parent)
    end

    def find_or_create_today_subfolder(category_name, date_time = @date_time)
      return if @opts[:local_write]
      parent = @remote_drive.find_nested([@term_code, category_name], on_failure: :error)
      find_or_create_folder(datestamp(date_time), parent)
    end

    def get_overrides_worksheet(klass)
      if (overrides_sheet = @remote_drive.find_nested [@term_code, 'overrides', klass.export_name])
        klass.from_csv @remote_drive.export_csv overrides_sheet
      end
    end

    def date_time_of_most_recent(category_name)
      # Deduce date from folder title
      parent = @remote_drive.find_nested([@term_code, category_name])
      folders = @remote_drive.find_folders(parent.id)
      unless (last = folders.sort_by(&:title).last)
        raise RuntimeError, "#{self.class.name} requires a non-empty '#{@term_code}/#{category_name}' folder"
      end
      log :info, "#{self.class.name} will pull data from '#{@term_code}/#{category_name}/#{last.title}'"
      DateTime.strptime(last.title, "#{self.class.date_format} #{self.class.timestamp_format}")
    rescue => e
      pattern = "#{Oec::Task.date_format}_#{Oec::Task.timestamp_format}"
      log :error, "Folder in '#{@term_code}/#{category_name}' failed to match '#{pattern}'.\n#{e.message}\n#{e.backtrace.join "\n\t"}"
      nil
    end

    def log(level, message)
      logger.send level, message
      @log << "[#{Time.now.strftime '%T'}] #{message}"
      write_status_to_cache if @opts[:log_to_cache]
    end

    def run_success_callback
      return if (condition = self.class.success_callback[:if]) && !instance_eval(&condition)
      task_opts = @opts.merge(previous_task_log: @log)
      self.class.success_callback[:class].new(task_opts).run
    end

    def timestamp(arg = @date_time)
      arg.strftime self.class.timestamp_format
    end

    def upload_file(path, remote_name, type, folder)
      @remote_drive.check_conflicts_and_upload(path, remote_name, type, folder,
        on_success: -> { log :debug, "Uploaded item #{path} to remote drive folder '#{folder.title}'" })
    end

    def upload_worksheet(worksheet, title, folder)
      @remote_drive.check_conflicts_and_upload(worksheet, title, Oec::Worksheet, folder,
        on_success: -> { log :debug, "Uploaded sheet '#{title}' to remote drive folder '#{folder.title}'" })
    end

    def write_log
      now = DateTime.now
      log_name = "#{timestamp now} #{self.class.name.demodulize.underscore.tr('_', ' ')}.log"
      log :debug, "Exporting log file '#{log_name}'"
      FileUtils.mkdir_p LOG_DIRECTORY unless File.exists? LOG_DIRECTORY
      # Local files need colons taken out of the timestamp, but remote sheets are happy to include them.
      log_path = LOG_DIRECTORY.join log_name.gsub(':', '')
      File.open(log_path, 'wb') { |f| f.puts @log }
      if @opts[:local_write]
        logger.debug "Wrote log file to path #{log_path}"
      else
        if (logs_today = find_or_create_today_subfolder('logs', now))
          begin
            upload_file(log_path, log_name, 'text/plain', logs_today)
          ensure
            File.delete log_path
          end
        end
      end
    rescue => e
      log :error, "Could not write log: #{e.message}\n#{e.backtrace.join "\n\t"}"
    end

    def write_status_to_cache
      previous_log_if_any = @opts[:previous_task_log] || []
      log = previous_log_if_any + @log
      self.class.write_cache(
        {status: @status, log: log},
        @api_task_id
      )
    end

  end
end
