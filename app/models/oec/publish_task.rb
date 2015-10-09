module Oec
  class PublishTask < Task

    include MergedSheetValidation

    attr_accessor :staging_dir

    def run_internal
      unless (export_sheets = build_and_validate_export_sheets)
        log :error, 'No files will be published'
        return
      end

      # The previous run might have failed to clean up properly so we wipe the slate clean before starting.
      @staging_dir = LOG_DIRECTORY.join 'explorance'
      FileUtils.rm_rf @staging_dir

      pattern = "#{Oec::Task.date_format}_%H%M%S"
      csv_staging_dir = @staging_dir.join("publish_#{@date_time.strftime pattern}")
      FileUtils.mkdir_p csv_staging_dir

      files_to_publish = []
      export_sheets.each do |sheet|
        sheet.export_directory = csv_staging_dir
        sheet.write_csv
        files_to_publish << "#{sheet.export_name}.csv"
      end

      # If local_write then our work is done; the staged CSVs will not be removed.
      unless @opts[:local_write]
        # SFTP stdout and stderr will go to a log file.
        FileUtils.mkdir_p LOG_DIRECTORY unless Dir.exists? LOG_DIRECTORY
        pattern = "#{Oec::Task.date_format}_#{Oec::Task.timestamp_format}"
        filename = "#{self.class.name.demodulize.underscore}_sftp_#{DateTime.now.strftime pattern}.log"
        sftp_stdout = LOG_DIRECTORY.join(filename).expand_path
        cmd = "#{sftp_command(csv_staging_dir, files_to_publish)} > #{sftp_stdout} 2>&1"
        if system(cmd)
          log :info, "Successfully ran system command: \n#{cmd}"
          # Now copy the command's output to remote drive.
          sftp_stdout_to_log sftp_stdout

          exports_now = find_or_create_now_subfolder 'exports'
          export_sheets.each do |sheet|
            export_sheet(sheet, exports_now)
          end
        else
          raise RuntimeError, "System command failed: \n----\n#{cmd}\n----\n"
        end
        FileUtils.rm_rf @staging_dir
      end
    end

    private

    def sftp_command(csv_staging_dir, files_to_publish)
      # SFTP batch-mode reads a series of commands from an input batch-file
      batch_file = "#{@staging_dir.expand_path}/batch_file.sftp"
      open(batch_file, 'w') { |f|
        f << "ls -la \n"
        files_to_publish.map do |file_to_put|
          f << "put #{csv_staging_dir.expand_path}/#{file_to_put} \n"
        end
        f << "exit \n"
      }
      settings = Settings.oec.explorance
      "sftp -v -b '#{batch_file}' -oPort=#{settings.sftp_port} -oIdentityFile=#{settings.ssh_private_key_file} #{settings.sftp_user}@#{settings.sftp_server}"
    end

    def sftp_stdout_to_log(sftp_output)
      if File.exists? sftp_output
        log = File.open(sftp_output, 'rb').read.gsub(/\r\n?/, "\n")
        log.each_line { |line| log(:info, line) }
      else
        log(:error, "SFTP log file not found: #{sftp_output}")
      end
    end

  end
end
