module Canvas
  class BatchEnrollments < Csv
    include ClassLogger

    # TODO Since canvas_section_id is not used by this class, enrollment refresh could probably use more refactoring...
    def refresh_enrollments_in_section(campus_section, course_id, section_id, teacher_role, canvas_section_id, enrollments_csv, known_users, users_csv)
      refresh_students_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
      refresh_teachers_in_section(campus_section, course_id, section_id, teacher_role, enrollments_csv, known_users, users_csv)
    end

    def refresh_students_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
      campus_data_rows = CampusOracle::Queries.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      campus_data_rows.each do |campus_data_row|
        if (role = ENROLL_STATUS_TO_CANVAS_SIS_ROLE[campus_data_row['enroll_status']])
          append_enrollment_and_user(role, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
        end
      end
    end

    def refresh_teachers_in_section(campus_section, course_id, section_id, teacher_role, enrollments_csv, known_users, users_csv)
      campus_data_rows = CampusOracle::Queries.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      campus_data_rows.each do |campus_data_row|
        append_enrollment_and_user(teacher_role, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
      end
    end

    def append_enrollment_and_user(role, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
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
end
