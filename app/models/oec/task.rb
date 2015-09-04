module Oec
  class Task
    include ClassLogger

    def initialize(opts)
      @log = []
      @remote_drive = Oec::RemoteDrive.new
      @term_code = opts.delete :term_code
      @opts = opts
      @tmp_path = Rails.root.join('tmp', 'oec')
      @course_code_filter = if opts[:dept_names]
                             {dept_name: opts[:dept_names].split}
                           elsif opts[:dept_codes]
                             {dept_code: opts[:dept_codes].split}
                           else
                             {dept_name: Oec::CourseCode.included_dept_names}
                           end
    end

    def run
      log :info, "Starting #{self.class.name}"
      run_internal
      true
    rescue => e
      log :error, "#{self.class.name} aborted with error: #{e.message}\n#{e.backtrace.join "\n\t"}"
      nil
    ensure
      write_log
    end

    private

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

    def datestamp
      DateTime.now.strftime '%F'
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
      worksheet = klass.new @tmp_path
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

    def find_or_create_today_subfolder(category_name)
      return if @opts[:local_write]
      parent = @remote_drive.find_nested([@term_code, category_name], on_failure: :error)
      find_or_create_folder(datestamp, parent)
    end

    def log(level, message)
      logger.send level, message
      @log << "[#{Time.now}] #{message}"
    end

    def timestamp
      DateTime.now.strftime '%H%M%S'
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
      log_name = "#{timestamp}_#{self.class.name.demodulize.underscore}.log"
      log :debug, "Exporting log file '#{log_name}'"
      File.open(@tmp_path.join(log_name), 'wb') { |f| f.puts @log }
      if @opts[:local_write]
        logger.debug "Wrote log file to path #{@tmp_path.join(log_name)}"
      else
        if (reports_today = find_or_create_today_subfolder('reports'))
          begin
            upload_file(@tmp_path.join(log_name), log_name, 'text/plain', reports_today)
          ensure
            File.delete @tmp_path.join(log_name)
          end
        end
      end
    rescue => e
      logger.error "Could not write log: #{e.message}\n#{e.backtrace.join "\n\t"}"
    end

  end
end
