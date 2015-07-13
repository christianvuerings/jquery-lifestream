module CanvasCsv
  # Provides user provisioning to Canvas based on UID array provided by 'Find a Person to Add' tool
  class UserProvision < Base

    def csv_filename_prefix
      @export_filename_prefix ||= "#{@export_dir}/user_provision-#{DateTime.now.strftime('%F')}-#{SecureRandom.hex(8)}"
    end

    # Imports users into Canvas from Oracle view based on UID array
    def import_users(user_ids)
      raise ArgumentError, 'User ID list is not an array' if user_ids.class != Array
      user_ids.each do |user_id|
        raise ArgumentError, "User ID list contains value that is not of type String - '#{user_id.to_s}'" if user_id.class != String
        raise ArgumentError, "User ID list contains value that is not numeric - '#{user_id.to_s}'" if (/^\-?\d*$/ =~ user_id).blank?
      end
      user_definitions = accumulate_user_data user_ids
      users_csv_file = make_users_csv("#{csv_filename_prefix}-users.csv", user_definitions)
      response = Canvas::SisImport.new.import_users users_csv_file
      if response.blank?
        logger.error "Failure importing users from #{users_csv_file}"
        raise RuntimeError, 'User import failed'
      else
        logger.warn "Successfully imported users from #{users_csv_file}"
        true
      end
    end

  end
end
