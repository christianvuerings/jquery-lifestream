class CanvasMaintainEnrollments < CanvasCsv
  include ClassLogger

  ENROLL_STATUS_TO_CANVAS_ROLE = {
    'E' => 'student',
    'W' => 'Waitlist Student',
    # Concurrent enrollment
    'C' => 'student'
  }

  def refresh_existing_term_sections(term, enrollments_csv, known_users, users_csv)
    canvas_sections_csv = CanvasSectionsReportProxy.new.get_csv(term)
    return if canvas_sections_csv.empty?
    canvas_sections_csv.each do |canvas_section|
      if (section_id = canvas_section['section_id'])
        if (course_id = canvas_section['course_id'])
          if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(section_id))
            refresh_students_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
            refresh_teachers_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
          end
        else
          logger.warn("Canvas section has SIS ID but course does not: #{canvas_section}")
        end
      end
    end
  end

  def refresh_students_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
    campus_data_rows = CampusData.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
    campus_data_rows.each do |campus_data_row|
      append_enrollment_and_user(course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
    end
  end

  def refresh_teachers_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
    campus_data_rows = CampusData.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
    campus_data_rows.each do |campus_data_row|
      append_teaching_and_user(course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
    end
  end

  def append_enrollment_and_user(course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
    if (role = ENROLL_STATUS_TO_CANVAS_ROLE[campus_data_row['enroll_status']])
      uid = campus_data_row['ldap_uid']
      enrollments_csv << {
        'course_id' => course_id,
        'user_id' => derive_sis_user_id(campus_data_row),
        'role' => role,
        'section_id' => section_id,
        'status' => 'active'
      }
      unless known_users.include?(uid)
        users_csv << canvas_user_from_campus_row(campus_data_row)
        known_users << uid
      end
    end
  end

  def append_teaching_and_user(course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
    uid = campus_data_row['ldap_uid']
    enrollments_csv << {
      'course_id' => course_id,
      'user_id' => derive_sis_user_id(campus_data_row),
      'role' => 'teacher',
      'section_id' => section_id,
      'status' => 'active'
    }
    unless known_users.include?(uid)
      users_csv << canvas_user_from_campus_row(campus_data_row)
      known_users << uid
    end
  end

end
