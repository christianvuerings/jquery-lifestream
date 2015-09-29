module Oec
  class PublishTask < Task

    def run_internal
      download_dir = download_exports_from_drive
      # If local_write then our work is done; the downloaded 'export' files will not be removed.
      unless @opts[:local_write]
        # SFTP stdout and stderr will go to a log file.
        FileUtils.mkdir_p LOG_DIRECTORY unless Dir.exists? LOG_DIRECTORY
        pattern = "#{Oec::Task.date_format}_#{Oec::Task.timestamp_format}"
        filename = "#{self.class.name.demodulize.underscore}_sftp_#{DateTime.now.strftime pattern}.log"
        sftp_stdout = LOG_DIRECTORY.join(filename).expand_path
        cmd = "#{sftp_command(download_dir)} > #{sftp_stdout} 2>&1"
        system(cmd) ? log(:info, "Successfully ran system command: #{cmd}") : raise(RuntimeError, "System command failed: \n----\n#{cmd}\n----\n")
        # Now copy the command's output to remote drive.
        sftp_stdout_to_log sftp_stdout
        FileUtils.rm_rf download_dir
      end
    end

    def files_to_publish
      %w(courses.csv course_instructors.csv course_students.csv course_supervisors.csv instructors.csv students.csv supervisors.csv)
    end

    private

    def download_exports_from_drive
      datetime_to_publish = @opts[:datetime_to_publish] || date_time_of_most_recent('exports')
      pattern = "#{Oec::Task.date_format}_%H%M%S"
      tmp_dir = LOG_DIRECTORY.join("publish_#{datetime_to_publish.strftime pattern}")
      FileUtils.mkdir_p tmp_dir
      parent = @remote_drive.find_nested([@term_code, 'exports', datetime_to_publish], on_failure: :error)
      files_to_publish.each do |filename|
        if (remote_content = @remote_drive.find_first_matching_item(filename.chomp('.csv'), parent))
          open(tmp_dir.join(filename), 'w') { |f|
            f << @remote_drive.export_csv(remote_content)
            f << "\n"
          }
        end
      end
      tmp_dir.to_s
    end

    def sftp_command(download_dir)
      settings = Settings.oec.explorance
      "lftp sftp://#{settings.sftp_user}@#{settings.sftp_server}:#{settings.sftp_port} -e '#{sftp_script download_dir}'"
    end

    def sftp_script(download_dir)
      download_dir.chomp!('/')
      put_files = files_to_publish.map { |file| " put #{download_dir}/#{file} " }.join("\n")
      %(
        #{put_files}
        exit
      )
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
