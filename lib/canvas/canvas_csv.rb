require 'csv'

class CanvasCsv
  include ClassLogger

  ENROLL_STATUS_TO_CANVAS_ROLE = {
      'E' => 'student',
      'W' => 'Waitlist Student',
      # Concurrent enrollment
      'C' => 'student'
  }

  def initialize
    @export_dir = Settings.canvas_proxy.export_directory
    if !File.exists?(@export_dir)
      FileUtils.mkdir_p(@export_dir)
    end
  end

  def accumulate_user_data(user_ids, users_csv)
    user_array = user_ids.to_a
    while !user_array.empty?
      slice_length = [user_array.length, 1000].min
      working_slice = user_array.slice!(0, slice_length)
      results = CampusData.get_basic_people_attributes(working_slice)
      results.each do |row|
        users_csv << {
            'user_id' => derive_sis_user_id(row),
            'login_id' => row['ldap_uid'],
            'first_name' => row['first_name'],
            'last_name' => row['last_name'],
            'email' => row['email_address'],
            'status' => 'active'
        }
      end
    end
    users_csv
  end

  def accumulate_section_enrollments(section, total_enrollments, total_users)
    section_id = section[:section_id]
    if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(section_id))
      section_enrollments = CampusData.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      section_enrollments.each do |enr|
        if (role = ENROLL_STATUS_TO_CANVAS_ROLE[enr['enroll_status']])
          uid = enr['ldap_uid']
          total_enrollments << {
              'course_id' => section[:course_id],
              'user_id' => derive_sis_user_id(enr),
              'role' => role,
              'section_id' => section_id,
              'status' => 'active'
          }
          total_users << canvas_user_from_campus_row(enr)
        end
      end
    else
      logger.warn("Badly formatted sis_section_id for Canvas section #{section}")
    end
    total_enrollments
  end

  def accumulate_section_instructors(section, total_enrollments, total_users)
    section_id = section[:section_id]
    if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(section_id))
      section_instructors = CampusData.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      section_instructors.each do |ins|
        uid = ins['ldap_uid']
        total_enrollments << {
            'course_id' => section[:course_id],
            'user_id' => derive_sis_user_id(ins),
            'role' => 'teacher',
            'section_id' => section_id,
            'status' => 'active'
        }
        total_users << canvas_user_from_campus_row(ins)
      end
    else
      logger.warn("Badly formatted sis_section_id for Canvas section #{section}")
    end
    total_enrollments
  end

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

  def make_csv(filename, headers, rows)
    csv = CSV.open(
        filename, 'wb',
        {
            headers: headers,
            write_headers: true
        }
    )
    if rows
      rows.each do |row|
        csv << row
      end
      csv.close
      filename
    else
      csv
    end
  end

  def make_courses_csv(filename, rows = nil)
    make_csv(filename, 'course_id,short_name,long_name,account_id,term_id,status,start_date,end_date', rows)
  end

  def make_enrollments_csv(filename, rows = nil)
    make_csv(filename, 'course_id,user_id,role,section_id,status,associated_user_id', rows)
  end

  def make_sections_csv(filename, rows = nil)
    make_csv(filename, 'section_id,course_id,name,status,start_date,end_date', rows)
  end

  def make_users_csv(filename, rows = nil)
    make_csv(filename, 'user_id,login_id,first_name,last_name,email,status', rows)
  end

end
