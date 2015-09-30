module Oec
  class PublishTask < Task

    def run_internal
      # The previous run might have failed to clean up properly so we wipe the slate clean before starting.
      @tmp_dir = LOG_DIRECTORY.join('explorance')
      FileUtils.rm_rf @tmp_dir
      FileUtils.mkdir_p @tmp_dir
      download_dir = download_exports_from_drive
      download_dir.chomp!('/')
      # If local_write then our work is done; the downloaded 'export' files will not be removed.
      unless @opts[:local_write]
        # SFTP stdout and stderr will go to a log file.
        FileUtils.mkdir_p LOG_DIRECTORY unless Dir.exists? LOG_DIRECTORY
        pattern = "#{Oec::Task.date_format}_#{Oec::Task.timestamp_format}"
        filename = "#{self.class.name.demodulize.underscore}_sftp_#{DateTime.now.strftime pattern}.log"
        sftp_stdout = LOG_DIRECTORY.join(filename).expand_path
        cmd = "#{sftp_command(download_dir)} > #{sftp_stdout} 2>&1"
        if system(cmd)
          log :info, "Successfully ran system command: \n#{cmd}"
        else
          raise RuntimeError, "System command failed: \n----\n#{cmd}\n----\n"
        end
        # Now copy the command's output to remote drive.
        sftp_stdout_to_log sftp_stdout
      end
      FileUtils.rm_rf @tmp_dir
    end

    def files_to_publish
      %w(courses.csv course_instructors.csv course_students.csv course_supervisors.csv instructors.csv students.csv supervisors.csv)
    end

    private

    def download_exports_from_drive
      datetime_to_publish = date_time_of_most_recent('exports')
      raise RuntimeError, 'The \'exports\' directory is empty; there is nothing to publish.' unless datetime_to_publish
      pattern = "#{Oec::Task.date_format}_%H%M%S"
      download_dir = @tmp_dir.join("publish_#{datetime_to_publish.strftime pattern}")
      FileUtils.mkdir_p download_dir
      directory = datetime_to_publish.strftime "#{Oec::Task.date_format} #{Oec::Task.timestamp_format}"
      parent = @remote_drive.find_nested([@term_code, 'exports', directory], on_failure: :error)
      files_to_publish.each do |filename|
        if (remote_content = @remote_drive.find_first_matching_item(filename.chomp('.csv'), parent))
          open(download_dir.join(filename), 'w') { |f|
            f << @remote_drive.export_csv(remote_content)
            f << "\n"
          }
        end
      end
      download_dir.to_s
    end

    def sftp_command(download_dir)
      # SFTP batch-mode reads a series of commands from an input batch-file
      batch_file = "#{@tmp_dir}/batch_file.sftp"
      open(batch_file, 'w') { |f|
        f << "ls -la \n"
        files_to_publish.map do |file_to_put|
          f << "put #{download_dir}/#{file_to_put} \n"
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
