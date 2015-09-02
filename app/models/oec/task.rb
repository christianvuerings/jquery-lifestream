module Oec
  class Task
    include ClassLogger

    def initialize(opts)
      @log = []
      uid = Settings.oec.google.uid
      @remote_drive = GoogleApps::SheetsManager.new(uid, Settings.oec.google.marshal_dump)
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

    def create_folder(folder_name, parent=nil)
      return if @opts[:local_write]
      if @remote_drive.find_folders_by_title(folder_name, folder_id(parent)).any?
        raise RuntimeError, "Folder '#{folder_name}' with parent '#{folder_title(parent)}' already exists on remote drive"
      else
        create_folder_no_existence_check(folder_name, parent)
      end
    end

    def export_sheet(worksheet, dest_folder)
      if @opts[:local_write]
        worksheet.export
        log :debug, "Exported local worksheet file '#{worksheet.output_filename}'"
      else
        upload_to_remote_drive(worksheet, worksheet.base_filename.chomp('.csv'), dest_folder)
      end
    end

    def find_or_create_folder(folder_name, parent=nil)
      find_folder(folder_name, parent) || create_folder_no_existence_check(folder_name, parent)
    end

    def create_folder_no_existence_check(folder_name, parent=nil)
      unless folder = @remote_drive.create_folder(folder_name, folder_id(parent))
        raise RuntimeError, "Could not create folder '#{folder_name}' on remote drive"
      end
      log :debug, "Created remote folder '#{folder_name}'"
      folder
    end

    def copy_file(file, dest_folder)
      if find_item(file.title, dest_folder)
        raise RuntimeError, "File '#{file.title}' already exists in remote drive folder '#{dest_folder.title}'; could not copy"
      end
      if (@remote_drive.copy_item_to_folder(file, dest_folder.id))
        log :debug, "Copied file '#{file.title}' to remote drive folder '#{dest_folder.title}'"
      else
        raise RuntimeError, "Could not copy file '#{file.title}' to '#{dest_folder.title}'"
      end
    end

    def datestamp
      DateTime.now.strftime '%F'
    end

    def find_folder(title, parent=nil)
      @remote_drive.find_folders_by_title(title, folder_id(parent)).first
    end

    def find_folders(parent=nil)
      @remote_drive.find_folders folder_id(parent)
    end

    def find_item(title, parent=nil)
      @remote_drive.find_items_by_title(title, parent_id: folder_id(parent)).first
    end

    def folder_id(folder)
      folder ? folder.id : 'root'
    end

    def folder_title(folder)
      folder ? folder.title : 'root'
    end

    def log(level, message)
      logger.send level, message
      @log << "[#{Time.now}] #{message}"
    end

    def timestamp
      DateTime.now.strftime '%H%M%S'
    end

    def upload_worksheet_headers(klass, dest_folder)
      worksheet = klass.new(@tmp_path)
      if @opts[:local_write]
        worksheet.export
        log :debug, "Exported local header-only file #{worksheet.output_filename}"
      else
        upload_to_remote_drive(worksheet, klass.name.demodulize.underscore, dest_folder)
      end
    end

    def upload_to_remote_drive(worksheet, title, folder)
      if @remote_drive.find_items_by_title(title, parent_id: folder.id).any?
        raise RuntimeError, "Item '#{title}' already exists in remote drive folder '#{folder.title}'; could not upload sheet"
      end
      if (!@remote_drive.upload_worksheet(title, '', worksheet, folder.id))
        raise RuntimeError, "Sheet '#{title}' could not be uploaded to remote drive folder '#{folder.title}'"
      end
      log :debug, "Uploaded sheet '#{title}' to remote drive folder '#{folder.title}'"
    end

    def upload_file(path, remote_name, type, folder)
      if @remote_drive.find_items_by_title(remote_name, parent_id: folder.id).any?
        raise RuntimeError, "Item '#{remote_name}' already exists in remote drive folder '#{folder.title}'; could not upload"
      end
      if (!@remote_drive.upload_file(remote_name, '', folder.id, type, path.to_s))
        raise RuntimeError, "File #{path} could not be uploaded to remote drive folder '#{folder.title}'"
      end
      log :debug, "Uploaded file #{path} to remote drive folder '#{folder.title}'"
    end

    def write_log
      if (reports_today = find_or_create_today_subfolder('reports'))
        log_name = "#{timestamp}_#{self.class.name.demodulize.underscore}.log"
        File.open(@tmp_path.join(log_name), 'wb') { |f| f.puts @log }
        unless @opts[:local_write]
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

    def find_or_create_today_subfolder(category_name)
      unless (term_folder = find_folder @term_code) && (folder = find_folder(category_name, term_folder))
        raise RuntimeError, "Could not locate '#{category_name}' folder on remote drive"
      end
      unless (today_folder = find_or_create_folder(datestamp, folder))
        raise RuntimeError, "Could not find_or_create '#{category_name}' folder dated #{datestamp} on remote drive"
      end
      today_folder
    end
  end
end
