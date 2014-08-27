module Canvas
  # Updates users currently present within Canvas.
  # Used by Canvas::RefreshAllCampusData to maintain officially enrolled students/faculty
  # See Canvas::MaintainAllUsers for updates/additions of all active CalNet users within Canvas
  class MaintainUsers < Csv
    include ClassLogger

    # Returns true if user hashes are identical
    def self.provisioned_account_eq_sis_account?(provisioned_account, sis_account)
      matched = provisioned_account['login_id'] == sis_account['login_id'] &&
        provisioned_account['email'] == sis_account['email']
      if matched && Settings.canvas_proxy.maintain_user_names
        matched = provisioned_account['first_name'] == sis_account['first_name'] &&
          provisioned_account['last_name'] == sis_account['last_name']
      end
      matched
    end

    # Any changes to SIS user IDs must take effect before the enrollments CSV is generated.
    # Otherwise, the generated CSV may include a new ID that does not match the existing ID for a user account.
    def self.handle_changed_sis_user_ids(sis_id_changes)
      if Settings.canvas_proxy.dry_run_import.present?
        logger.warn("DRY RUN MODE: Would change #{sis_id_changes.length} SIS user IDs #{sis_id_changes.inspect}")
      else
        logger.warn("About to change #{sis_id_changes.length} SIS user IDs")
        sis_id_changes.each do |canvas_user_id, new_sis_id|
          self.change_sis_user_id(canvas_user_id, new_sis_id)
        end
      end
    end

    # Updates SIS User ID for Canvas User
    #
    # Because there is no way to do a bulk download of user login objects, two Canvas requests are required to
    # set each user's SIS user ID.
    def self.change_sis_user_id(canvas_user_id, new_sis_user_id)
      logins_proxy = Canvas::Logins.new
      response = logins_proxy.user_logins(canvas_user_id)
      if response && response.status == 200
        user_logins = JSON.parse(response.body)
        # We look for the login with a numeric "unique_id", and assume it is an LDAP UID.
        user_logins.select! do |login|
          begin
            Integer(login['unique_id'], 10)
            true
          rescue ArgumentError
            false
          end
        end
        if user_logins.length > 1
          logger.error("Multiple numeric logins found for Canvas user #{canvas_user_id}; will skip")
        elsif user_logins.empty?
          logger.warn("No LDAP UID login found for Canvas user #{canvas_user_id}; will skip")
        else
          login_id = user_logins[0]['id']
          logger.warn("Changing SIS ID for user #{canvas_user_id} to #{new_sis_user_id}")
          response = logins_proxy.change_sis_user_id(login_id, new_sis_user_id)
          return true if response && response.status == 200
        end
      end
      false
    end

    # Appends account changes to the given CSV.
    # Appends all known user IDs to the input array.
    # Makes any necessary changes to SIS user IDs.
    def refresh_existing_user_accounts(known_uids, users_csv)
      sis_id_changes = {}
      check_all_user_accounts(known_uids, sis_id_changes, users_csv)
      self.class.handle_changed_sis_user_ids(sis_id_changes)
    end

    def check_all_user_accounts(known_uids, sis_id_changes, account_changes)
      # As the size of the CSV grows, it will become more efficient to use CSV.foreach.
      # For now, however, we ingest the entire download.
      users_csv = Canvas::UsersReport.new.get_csv
      if users_csv.present?
        accounts_batch = []
        users_csv.each do |account_row|
          accounts_batch << account_row
          if accounts_batch.length == 1000
            compare_to_campus(accounts_batch, known_uids, sis_id_changes, account_changes)
            accounts_batch = []
          end
        end
        compare_to_campus(accounts_batch, known_uids, sis_id_changes, account_changes)
      end
    end

    def compare_to_campus(accounts_batch, known_uids, sis_id_changes, account_changes)
      campus_user_rows = CampusOracle::Queries.get_basic_people_attributes(accounts_batch.collect { |r| r['login_id'] })
      accounts_batch.each do |existing_account|
        categorize_user_account(existing_account, campus_user_rows, known_uids, sis_id_changes, account_changes)
      end
    end

    def categorize_user_account(existing_account, campus_user_rows, known_uids, sis_id_changes, account_changes)
      # Convert from CSV::Row for easier manipulation.
      old_account_data = existing_account.to_hash
      login_id = old_account_data['login_id']
      if (ldap_uid = Integer(login_id, 10) rescue nil)
        campus_row = campus_user_rows.select { |r| r['ldap_uid'].to_i == ldap_uid }.first
        if campus_row.present?
          known_uids << login_id
          new_account_data = canvas_user_from_campus_row(campus_row)
          if old_account_data['user_id'] != new_account_data['user_id']
            sis_id_changes["sis_login_id:#{old_account_data['login_id']}"] = new_account_data['user_id']
          end
          unless self.class.provisioned_account_eq_sis_account?(old_account_data, new_account_data)
            account_changes << new_account_data
          end
        end
      end
    end

  end
end
