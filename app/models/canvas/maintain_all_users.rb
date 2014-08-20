module Canvas
  # Updates and adds Canvas users based on differences detected in active CalNet user set and Canvas User Report
  class MaintainAllUsers < Csv

    def initialize(options = {})
      default_options = { :clear_sis_stickiness => false }
      options.reverse_merge!(default_options)

      super()
      @sis_user_id_updates = {}
      @clear_sis_stickiness = options[:clear_sis_stickiness]
    end

    # Performs full active user synchronization task
    def sync_all_active_users
      prepare_sis_user_import
      get_canvas_user_report_file
      load_active_users
      process_updated_users
      process_new_users
      Canvas::MaintainUsers.handle_changed_sis_user_ids(@sis_user_id_updates)
      import_sis_user_csv
    end

    def prepare_sis_user_import
      sis_user_import_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-sync-all-users.csv"
      @sis_user_import = make_users_csv(sis_user_import_filename)
    end

    # Prepares Canvas report containing all users for iteration during processing
    def get_canvas_user_report_file
      get_report = Proc.new {
        filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-users-report.csv"
        csv_table = Canvas::UsersReport.new.get_csv
        headers = csv_table.headers.join(',')
        file = CSV.open(filename, 'wb', { :headers => headers, :write_headers => true})
        logger.warn("Performing user update checks on #{csv_table.count} provisioned user accounts")
        csv_table.each do |row|
          file << row
        end
        file.close
        file.path
      }
      @canvas_user_report_file_path ||= get_report.call
    end

    # Loads active LDAP people/guests from campus Oracle view
    def load_active_users
      @active_sis_users = {}
      CampusOracle::Queries.get_all_active_people_attributes.each do |person|
        @active_sis_users[person['ldap_uid']] = person
      end
    end

    # Compares users in Canvas with state in campus data set for updates.
    # Adds updated users to SIS User import CSV, records users needing SIS User ID update.
    # Removes users existing in Canvas from active user list to leave new users remaining in @active_sis_users hash.
    def process_updated_users
      CSV.foreach(get_canvas_user_report_file, :headers => :first_row) do |canvas_user|
        uid = canvas_user['login_id']

        # process only if found in campus data
        if @active_sis_users[uid]
          active_campus_user = canvas_user_from_campus_row(@active_sis_users[uid])

          # if SIS User ID has changed
          if canvas_user['user_id'] != active_campus_user['user_id']
            @sis_user_id_updates["sis_login_id:#{canvas_user['login_id']}"] = active_campus_user['user_id']
          end

          unless Canvas::MaintainUsers.provisioned_account_eq_sis_account?(canvas_user, active_campus_user)
            logger.debug("Updating user #{canvas_user} with #{active_campus_user}")
            add_user_to_import(active_campus_user)
          end
          @active_sis_users.delete(uid)
        end
      end
    end

    # Add remaining users not detected in Canvas to SIS User Import
    def process_new_users
      logger.warn("#{@active_sis_users.length} new user accounts detected. Adding to SIS User Import CSV")
      @active_sis_users.values.each do |new_user|
        new_canvas_user = canvas_user_from_campus_row(new_user)
        add_user_to_import(new_canvas_user)
      end
      @active_sis_users = nil
    end

    # Adds Canvas User hash to SIS User Import CSV
    def add_user_to_import(canvas_user)
      @sis_user_import << canvas_user
    end

    def import_sis_user_csv
      @sis_user_import.close
      csv_filepath = @sis_user_import.path
      user_count = CSV.read(csv_filepath, {headers: true}).length
      if user_count > 0
        params = ''
        params = '&override_sis_stickiness=1&clear_sis_stickiness=1' if @clear_sis_stickiness
        logger.warn("Importing SIS User Import CSV with #{user_count} updates - Params: #{params}")
        Canvas::SisImport.new.import_users(csv_filepath, params)
      end
    end

  end
end
