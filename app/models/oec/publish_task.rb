module Oec
  class PublishTask < Task

    def run_internal
      download_dir = download_exports_from_drive
      # SFTP stdout and stderr will go to a log file.
      FileUtils.mkdir_p LOG_DIRECTORY unless Dir.exists? LOG_DIRECTORY
      filename = "#{self.class.name.demodulize.underscore}_sftp_#{DateTime.now.strftime '%F_%H:%M:%S'}.log"
      sftp_stdout = LOG_DIRECTORY.join(filename).expand_path
      cmd = "#{sftp_command(download_dir)} > #{sftp_stdout} 2>&1"
      system(cmd) ? log(:info, "Successfully ran system command: #{cmd}") : raise(RuntimeError, "System command failed: #{cmd}")
      # Now copy the command's output to remote drive.
      sftp_stdout_to_log sftp_stdout
      FileUtils.rm_rf download_dir
    end

    def files_to_publish
      %w(courses.csv course_instructors.csv course_students.csv course_supervisors.csv instructors.csv students.csv supervisors.csv)
    end

    private

    def download_exports_from_drive
      date_to_publish = @opts[:date_to_publish] || datestamp
      tmp_dir = LOG_DIRECTORY.join("publish_#{date_to_publish}")
      FileUtils.mkdir_p tmp_dir
      parent = @remote_drive.find_nested([@term_code, 'exports', date_to_publish], on_failure: :error)
      files_to_publish.each do |filename|
        remote_content = @remote_drive.find_first_matching_item(filename.chomp('.csv'), parent)
        open(tmp_dir.join(filename), 'w') { |f|
          f << @remote_drive.export_csv(remote_content)
          f << "\n"
        }
      end
      tmp_dir.to_s
    end

    def sftp_command(download_dir)
      e = Settings.oec.explorance
      cmd = "lftp sftp://#{e.sftp_user}"
      # If password is blank then SSH key-based auth
      cmd.concat ":#{e.sftp_password}" unless e.sftp_password.blank?
      cmd.concat "@#{e.sftp_server}:#{e.sftp_port} -e '#{sftp_script download_dir}'"
      cmd
    end

    def sftp_script(download_dir)
      download_dir.chomp!('/')
      put_files = files_to_publish.map { |file| "put #{download_dir}/#{file}" }.join("\n")
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
