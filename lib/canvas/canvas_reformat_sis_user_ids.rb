class CanvasReformatSisUserIds < CanvasCsv
  include ClassLogger

  def convert_all_sis_user_ids
    # Get the current Canvas user IDs.
    ldap_to_canvas_ids = fetch_canvas_user_id_map
    ldap_ids = ldap_to_canvas_ids.keys
    all_users_count = ldap_ids.length
    changed_users_count = 0
    # Work in chunks of up to 1000 users.
    while !ldap_ids.empty?
      slice_length = [ldap_ids.length, 1000].min
      working_slice = ldap_ids.slice!(0, slice_length)
      campus_users = CampusData.get_basic_people_attributes(working_slice)
      campus_users.each do |campus_user|
        new_sis_user_id = derive_sis_user_id(campus_user)
        canvas_ids = ldap_to_canvas_ids[campus_user['ldap_uid'].to_s]
        if canvas_ids && canvas_ids[:sis_user_id] != new_sis_user_id
          logger.info("Will change SIS user ID for #{campus_user['ldap_uid']} from #{canvas_ids[:sis_user_id]} to #{new_sis_user_id}")
          change_sis_user_id(canvas_ids[:canvas_user_id], new_sis_user_id)
          changed_users_count += 1
        end
      end
    end
    logger.warn("Changed SIS IDs for #{changed_users_count} out of #{all_users_count} users")
  end

  # Because there is no way to do a bulk download of user login objects, two Canvas requests are required to
  # set each user's SIS user ID. This method should only be called when the SIS user ID needs changing.
  def change_sis_user_id(canvas_user_id, new_sis_user_id)
    logins_proxy = CanvasLoginsProxy.new
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
        logger.warn("Multiple numeric logins found for Canvas user #{canvas_user_id}; will skip")
      elsif user_logins.empty?
        logger.warn("No LDAP UID login found for Canvas user #{canvas_user_id}; will skip")
      else
        login_id = user_logins[0]['id']
        response = logins_proxy.change_sis_user_id(login_id, new_sis_user_id)
        return true if response && response.status == 200
      end
    end
    false
  end

  def fetch_canvas_user_id_map
    ids_map = {}
    # Download a report of all Canvas user accounts.
    users_csv = CanvasUsersReportProxy.new.get_csv
    if users_csv
      users_csv.each do |user|
        login_id = user['login_id']
        # Assume that a simple integer login_id is meant to be reached through CAS.
        # The usual Integer("042", 10) check is insufficient because a LDAP_UID of 42 would not
        # match the login_id.
        if login_id.to_i.to_s == login_id
          ids_map[login_id] = {
              canvas_user_id: user['canvas_user_id'],
              sis_user_id: user['user_id'].to_s
          }
        end
      end
    end
    ids_map
  end

end