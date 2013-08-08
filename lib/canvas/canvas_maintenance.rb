require 'csv'

class CanvasMaintenance

  def canvas_user_from_campus_row(campus_user)
    {
        'user_id' => derive_sis_user_id(campus_user),
        'login_id' => campus_user['ldap_uid'],
        'first_name' => campus_user['first_name'],
        'last_name' => campus_user['last_name'],
        'email' => campus_user['email_address'],
        'status' => 'active'
    }
  end

  # Returns the number of non-duplicate rows.
  def csv_without_duplications(raw_csv_filename, new_csv_filename)
    count = 0
    CSV.open(new_csv_filename, 'w') do |csv|
      CSV.read(raw_csv_filename).uniq.each do |row|
        csv << row
        count += 1
      end
    end
    count
  end

  def derive_sis_user_id(campus_user)
    if Settings.canvas_proxy.mixed_sis_user_id
      if CampusData.is_student?(campus_user)
        campus_user['student_id'].to_s
      else
        "UID:#{campus_user['ldap_uid']}"
      end
    else
      campus_user['ldap_uid'].to_s
    end
  end

end
