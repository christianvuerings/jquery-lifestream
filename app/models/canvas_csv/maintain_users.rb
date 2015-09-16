module CanvasCsv
  # Updates users currently present within Canvas.
  # Used by CanvasCsv::RefreshAllCampusData to maintain officially enrolled students/faculty
  # See CanvasCsv::AddNewUsers for maintenance of new active CalNet users within Canvas
  class MaintainUsers < Base
    include ClassLogger
    attr_accessor :sis_user_id_changes, :user_email_deletions

    # Returns true if user hashes are identical
    def self.provisioned_account_eq_sis_account?(provisioned_account, sis_account)
      # Canvas interprets an empty 'email' column as 'Do not change.'
      matched = provisioned_account['login_id'] == sis_account['login_id'] &&
        (sis_account['email'].blank? || (provisioned_account['email'] == sis_account['email']))
      if matched && Settings.canvas_proxy.maintain_user_names
        # Canvas plays elaborate games with user name imports. See the RSpec for examples.
        matched = provisioned_account['full_name'] == "#{sis_account['first_name']} #{sis_account['last_name']}"
      end
      matched
    end

    # Updates SIS User ID for Canvas User
    #
    # Because there is no way to do a bulk download of user login objects, two Canvas requests are required to
    # set each user's SIS user ID.
    def self.change_sis_user_id(canvas_user_id, new_sis_user_id)
      logins_proxy = Canvas::Logins.new
      response = logins_proxy.user_logins(canvas_user_id)
      if (user_logins = response[:body])
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
          logger.error "Multiple numeric logins found for Canvas user #{canvas_user_id}; will skip"
        elsif user_logins.empty?
          logger.warn "No LDAP UID login found for Canvas user #{canvas_user_id}; will skip"
        else
          login_id = user_logins[0]['id']
          logger.debug "Changing SIS ID for user #{canvas_user_id} to #{new_sis_user_id}"
          response = logins_proxy.change_sis_user_id(login_id, new_sis_user_id)
          return true if response[:statusCode] == 200
        end
      end
      false
    end

    def initialize(known_uids, sis_user_import_csv)
      super()
      @known_uids = known_uids
      @user_import_csv = sis_user_import_csv
      @sis_user_id_changes = {}
      @user_email_deletions = []
    end

    # Appends account changes to the given CSV.
    # Appends all known user IDs to the input array.
    # Makes any necessary changes to SIS user IDs.
    def refresh_existing_user_accounts
      check_all_user_accounts
      handle_changed_sis_user_ids
      if Settings.canvas_proxy.delete_bad_emails.present?
        handle_email_deletions @user_email_deletions
      else
        logger.warn "EMAIL DELETION BLOCKED: Would delete email addresses for #{@user_email_deletions.length} inactive users: #{@user_email_deletions}"
      end
    end

    def check_all_user_accounts
      # As the size of the CSV grows, it will become more efficient to use CSV.foreach.
      # For now, however, we ingest the entire download.
      users_csv = Canvas::Report::Users.new.get_csv
      if users_csv.present?
        accounts_batch = []
        users_csv.each do |account_row|
          accounts_batch << account_row
          if accounts_batch.length == 1000
            compare_to_campus(accounts_batch)
            accounts_batch = []
          end
        end
        compare_to_campus(accounts_batch) if accounts_batch.present?
      end
    end

    # Any changes to SIS user IDs must take effect before the enrollments CSV is generated.
    # Otherwise, the generated CSV may include a new ID that does not match the existing ID for a user account.
    def handle_changed_sis_user_ids
      if Settings.canvas_proxy.dry_run_import.present?
        logger.warn "DRY RUN MODE: Would change #{@sis_user_id_changes.length} SIS user IDs #{@sis_user_id_changes.inspect}"
      else
        logger.warn "About to change #{@sis_user_id_changes.length} SIS user IDs"
        @sis_user_id_changes.each do |canvas_user_id, new_sis_id|
          self.class.change_sis_user_id(canvas_user_id, new_sis_id)
        end
      end
    end

    def handle_email_deletions(canvas_user_ids)
      logger.warn "About to delete email addresses for #{canvas_user_ids.length} inactive users: #{canvas_user_ids}"
      canvas_user_ids.each do |canvas_user_id|
        proxy = Canvas::CommunicationChannels.new(canvas_user_id: canvas_user_id)
        if (channels = proxy.list[:body])
          channels.each do |channel|
            if channel['type'] == 'email'
              channel_id = channel['id']
              dry_run = Settings.canvas_proxy.dry_run_import
              if dry_run.present?
                logger.warn "DRY RUN MODE: Would delete communication channel #{channel}"
              else
                proxy.delete channel_id
              end
            end
          end
        end
      end
    end

    def categorize_user_account(existing_account, campus_user_rows)
      # Convert from CSV::Row for easier manipulation.
      old_account_data = existing_account.to_hash
      login_id = old_account_data['login_id']
      if (inactive_account = /^inactive-([0-9]+)$/.match login_id)
        login_id = inactive_account[1]
      end
      if (ldap_uid = Integer(login_id, 10) rescue nil)
        campus_row = campus_user_rows.select { |r| r['ldap_uid'].to_i == ldap_uid }.first
        if campus_row.present?
          logger.warn "Reactivating account for LDAP UID #{ldap_uid}" if inactive_account
          @known_uids << login_id
          new_account_data = canvas_user_from_campus_row(campus_row)
        else
          # This LDAP UID no longer appears in campus data. Mark the Canvas user account as inactive.
          logger.warn "Inactivating account for LDAP UID #{ldap_uid}" unless inactive_account
          if old_account_data['email'].present?
            @user_email_deletions << old_account_data['canvas_user_id']
          end
          new_account_data = old_account_data.merge(
            'login_id' => "inactive-#{ldap_uid}",
            'user_id' => "UID:#{ldap_uid}",
            'email' => nil
          )
        end
        if old_account_data['user_id'] != new_account_data['user_id']
          logger.warn "Will change SIS ID for user sis_login_id:#{old_account_data['login_id']} from #{old_account_data['user_id']} to #{new_account_data['user_id']}"
          @sis_user_id_changes["sis_login_id:#{old_account_data['login_id']}"] = new_account_data['user_id']
        end
        unless self.class.provisioned_account_eq_sis_account?(old_account_data, new_account_data)
          @user_import_csv << new_account_data
        end
      end
    end

    def compare_to_campus(accounts_batch)
      campus_user_rows = CampusOracle::Queries.get_basic_people_attributes(accounts_batch.collect { |r| r['login_id'] })
      accounts_batch.each do |existing_account|
        categorize_user_account(existing_account, campus_user_rows)
      end
    end

  end
end
