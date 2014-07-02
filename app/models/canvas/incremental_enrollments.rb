module Canvas
  class IncrementalEnrollments < Csv
    include ClassLogger

    # Roles indicated by Canvas Enrollments API
    ENROLL_STATUS_TO_CANVAS_ROLE = {
      'E' => 'StudentEnrollment',
      'W' => 'Waitlist Student',
      'C' => 'StudentEnrollment'
    }

    CANVAS_ROLE_TO_CANVAS_SIS_ROLE = {
      'StudentEnrollment' => 'student',
      'Waitlist Student' => 'Waitlist Student',
      'TeacherEnrollment' => 'teacher',
    }

    def self.canvas_section_enrollments(canvas_section_id)
      raise ArgumentError, "canvas_section_id must be a Fixnum" if canvas_section_id.class != Fixnum
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

    def refresh_existing_term_sections(term, enrollments_csv, known_users, users_csv)
      canvas_sections_csv = Canvas::SectionsReport.new.get_csv(term)
      return if canvas_sections_csv.empty?
      canvas_sections_csv.each do |canvas_section|
        if (section_id = canvas_section['section_id'])
          if (course_id = canvas_section['course_id'])
            canvas_section_id = Integer(canvas_section['canvas_section_id'], 10)
            canvas_enrollments = self.class.canvas_section_enrollments(canvas_section_id)
            if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(section_id))
              refresh_students_in_section(campus_section, course_id, section_id, canvas_enrollments[:students], enrollments_csv, known_users, users_csv)
              refresh_teachers_in_section(campus_section, course_id, section_id, canvas_enrollments[:instructors], enrollments_csv, known_users, users_csv)
            end
          else
            logger.warn("Canvas section has SIS ID but course does not: #{canvas_section}")
          end
        end
      end
    end

    def refresh_students_in_section(campus_section, course_id, section_id, canvas_student_enrollments, enrollments_csv, known_users, users_csv)
      campus_data_rows = CampusOracle::Queries.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      campus_data_rows.each do |campus_data_row|
        enrollee_uid = campus_data_row['ldap_uid'].to_s
        # Append student for update if found. Remove from Canvas enrollment list
        if canvas_student_enrollments.has_key?(enrollee_uid)
          if canvas_student_enrollment_needs_update?(campus_data_row, canvas_student_enrollments[enrollee_uid])
            append_enrollment_and_user('student', course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
          end
          # Remove from Canvas enrollment list
          canvas_student_enrollments.delete(enrollee_uid)
          # Otherwise add new enrollment
        else
          append_enrollment_and_user('student', course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
        end
      end
      # Handle enrollments remaining in Canvas enrollment list
      canvas_student_enrollments.each { |uid, remaining_enrollment| handle_missing_enrollment(uid, course_id, section_id, remaining_enrollment, enrollments_csv) }
    end

    def handle_missing_enrollment(uid, course_id, section_id, enrollment, enrollments_csv)
      logger.info "No campus record for Canvas enrollment in #{enrollment['course_id']} #{enrollment['section_id']} for user #{uid} with role #{enrollment['role']}"
      # Only drop enrollments if they originated from an SIS Import
      if enrollment["sis_import_id"].present?
        canvas_role = CANVAS_ROLE_TO_CANVAS_SIS_ROLE[enrollment['role']]
        sis_user_id = enrollment['user']['sis_user_id']
        append_enrollment_deletion(course_id, section_id, canvas_role, sis_user_id, enrollments_csv)
      end
    end

    def refresh_teachers_in_section(campus_section, course_id, section_id, canvas_instructor_enrollments, enrollments_csv, known_users, users_csv)
      campus_data_rows = CampusOracle::Queries.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      campus_data_rows.each do |campus_data_row|
        enrollee_uid = campus_data_row['ldap_uid'].to_s
        # Remove instructor from Canvas enrollment list if already present
        if canvas_instructor_enrollments.has_key?(enrollee_uid)
          canvas_instructor_enrollments.delete(enrollee_uid)
          # Otherwise add new enrollment
        else
          append_enrollment_and_user('instructor', course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
        end
      end
      # Handle enrollments remaining in Canvas enrollment list
      canvas_instructor_enrollments.each { |uid, remaining_enrollment| handle_missing_enrollment(uid, course_id, section_id, remaining_enrollment, enrollments_csv) }
    end

    # Adds/updates enrollments, for both students and teachers
    def append_enrollment_and_user(enrollment_type, course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv)
      enrollment_types = ['student', 'instructor']
      sentence_options = {:last_word_connector => ', or ', :two_words_connector => ' or '}
      raise ArgumentError, "Enrollment type argument '#{enrollment_type}' invalid. Must be #{enrollment_types.to_sentence(sentence_options)}." unless enrollment_types.include?(enrollment_type)

      if enrollment_type == 'student'
        role = ENROLL_STATUS_TO_CANVAS_SIS_ROLE[campus_data_row['enroll_status']]
        return nil unless role
      elsif enrollment_type == 'instructor'
        role = 'teacher'
      end

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

    # Returns true if canvas student enrollment differs from campus enrollment state
    def canvas_student_enrollment_needs_update?(campus_student_enrollment, canvas_student_enrollment)
      return true if canvas_student_enrollment['role'] != ENROLL_STATUS_TO_CANVAS_ROLE[campus_student_enrollment['enroll_status']]
      return false
    end

  end
end
