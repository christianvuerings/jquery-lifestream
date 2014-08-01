module Canvas
  class IncrementalEnrollments < Csv
    include ClassLogger

    # Roles indicated by Canvas Enrollments API
    ENROLL_STATUS_TO_CANVAS_ROLE = {
      'E' => 'StudentEnrollment',
      'W' => 'Waitlist Student',
      'C' => 'StudentEnrollment'
    }

    CANVAS_API_ROLE_TO_CANVAS_SIS_ROLE = {
      'StudentEnrollment' => 'student',
      'TaEnrollment' => 'ta',
      'TeacherEnrollment' => 'teacher'
    }
    CANVAS_SIS_ROLE_TO_CANVAS_API_ROLE = CANVAS_API_ROLE_TO_CANVAS_SIS_ROLE.invert

    def self.canvas_section_enrollments(canvas_section_id)
      canvas_section_id = Integer(canvas_section_id, 10)
      canvas_section_enrollments = Canvas::SectionEnrollments.new(:section_id => canvas_section_id).list_enrollments

      # Filter out non-SIS user enrollments
      sis_user_filter = lambda { |e| !e['user'].has_key?('sis_user_id') }
      if (non_sis_enrollments = canvas_section_enrollments.select(&sis_user_filter)) && !non_sis_enrollments.empty?
        canvas_section_enrollments.reject!(&sis_user_filter)
        user_ids = non_sis_enrollments.collect { |e| e['user']['id'] }.join(', ')
        logger.warn("Canvas User IDs - #{user_ids} - enrolled in Canvas Section ID # #{canvas_section_id} without SIS User ID present")
      end

      canvas_student_enrollments_array = canvas_section_enrollments.select { |e| e['type'] == 'StudentEnrollment' }
      canvas_instructor_enrollments_array = canvas_section_enrollments.select { |e| e['type'] == 'TeacherEnrollment' }
      canvas_student_enrollments_hash = Hash[canvas_student_enrollments_array.map { |u| [u['user']['login_id'], u] }]
      canvas_instructor_enrollments_hash = Hash[canvas_instructor_enrollments_array.map { |u| [u['user']['login_id'], u] }]
      return {:students => canvas_student_enrollments_hash, :instructors => canvas_instructor_enrollments_hash}
    end

    def refresh_enrollments_in_section(campus_section, course_id, section_id, teacher_role, canvas_section_id, enrollments_csv, known_users, users_csv)
      canvas_enrollments = self.class.canvas_section_enrollments(canvas_section_id)
      refresh_students_in_section(campus_section, course_id, section_id, canvas_enrollments[:students], enrollments_csv, known_users, users_csv)
      refresh_teachers_in_section(campus_section, course_id, section_id, teacher_role, canvas_enrollments[:instructors], enrollments_csv, known_users, users_csv)
    end

    def refresh_students_in_section(campus_section, course_id, section_id, canvas_student_enrollments, enrollments_csv, known_users, users_csv)
      campus_data_rows = CampusOracle::Queries.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      campus_data_rows.each do |campus_data_row|
        enrollee_uid = campus_data_row['ldap_uid'].to_s
        next unless (canvas_role = ENROLL_STATUS_TO_CANVAS_ROLE[campus_data_row['enroll_status']])
        # No action needed if the student is already present with the same role, so remove it from the list.
        if canvas_student_enrollments.has_key?(enrollee_uid) &&
          canvas_student_enrollments[enrollee_uid]['role'] == canvas_role
          canvas_student_enrollments.delete(enrollee_uid)
        else
          # Otherwise add the new enrollment. Any existing enrollments with a different role will be removed later.
          append_enrollment_and_user(api_role_to_csv_role(canvas_role), course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
        end
      end
      # Handle enrollments remaining in Canvas enrollment list
      canvas_student_enrollments.each { |uid, remaining_enrollment| handle_missing_enrollment(uid, course_id, section_id, remaining_enrollment, enrollments_csv) }
    end

    def handle_missing_enrollment(uid, course_id, section_id, enrollment, enrollments_csv)
      logger.info "No campus record for Canvas enrollment in #{enrollment['course_id']} #{enrollment['section_id']} for user #{uid} with role #{enrollment['role']}"
      # Only drop enrollments if they originated from an SIS Import
      if enrollment["sis_import_id"].present?
        sis_user_id = enrollment['user']['sis_user_id']
        append_enrollment_deletion(course_id, section_id, api_role_to_csv_role(enrollment['role']), sis_user_id, enrollments_csv)
      end
    end

    def refresh_teachers_in_section(campus_section, course_id, section_id, teacher_role, canvas_instructor_enrollments, enrollments_csv, known_users, users_csv)
      canvas_api_role = CANVAS_SIS_ROLE_TO_CANVAS_API_ROLE[teacher_role]
      campus_data_rows = CampusOracle::Queries.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      campus_data_rows.each do |campus_data_row|
        enrollee_uid = campus_data_row['ldap_uid'].to_s
        # No action needed if the instructor is already present with the same role, so remove it from the list.
        if canvas_instructor_enrollments.has_key?(enrollee_uid) &&
          canvas_instructor_enrollments[enrollee_uid]['role'] == canvas_api_role
          canvas_instructor_enrollments.delete(enrollee_uid)
        else
          # Otherwise add the new enrollment. Any existing enrollments with a different role will be removed later.
          append_enrollment_and_user(teacher_role, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
        end
      end
      # Handle enrollments remaining in Canvas enrollment list
      canvas_instructor_enrollments.each { |uid, remaining_enrollment| handle_missing_enrollment(uid, course_id, section_id, remaining_enrollment, enrollments_csv) }
    end

    # Adds/updates enrollments, for both students and teachers
    def append_enrollment_and_user(canvas_role, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
      uid = campus_data_row['ldap_uid']
      enrollments_csv << {
        'course_id' => course_id,
        'user_id' => derive_sis_user_id(campus_data_row),
        'role' => canvas_role,
        'section_id' => section_id,
        'status' => 'active'
      }
      unless known_users.include?(uid)
        users_csv << canvas_user_from_campus_row(campus_data_row)
        known_users << uid
      end
    end

    # Appends enrollment record for deletion
    def append_enrollment_deletion(course_id, section_id, canvas_role, sis_user_id, enrollments_csv)
      enrollments_csv << {
        'course_id' => course_id,
        'user_id' => sis_user_id,
        'role' => canvas_role,
        'section_id' => section_id,
        'status' => 'deleted'
      }
    end

    # For certain built-in enrollment roles, the Canvas enrollments API shows the
    # enrollment-type category (e.g., "StudentEnrollment") in place of the CSV-import-friendly
    # role (e.g., "student"). This is probably a bug, but we need to deal with it.
    # For customized enrollment roles, the "role" shown in the API is the same as used
    # in CSV imports.
    def api_role_to_csv_role(canvas_role)
      CANVAS_API_ROLE_TO_CANVAS_SIS_ROLE[canvas_role] || canvas_role
    end

  end
end
