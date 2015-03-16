module Canvas
  class SiteMembershipsMaintainer < Csv
    include TorqueBox::Messaging::Backgroundable
    include ClassLogger

    # Roles indicated by Canvas Enrollments API
    ENROLL_STATUS_TO_CANVAS_API_ROLE = {
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

    def self.process(sis_course_id, sis_section_ids, enrollments_csv_output, users_csv_output, known_users, batch_mode = false, cached_enrollments_provider = nil, sis_user_id_changes = {})
      logger.info("Processing refresh of enrollments for SIS Course ID '#{sis_course_id}'")
      worker = Canvas::SiteMembershipsMaintainer.new(sis_course_id, sis_section_ids,
        enrollments_csv_output, users_csv_output, known_users, :batch_mode => batch_mode, :cached_enrollments_provider => cached_enrollments_provider, :sis_user_id_changes => sis_user_id_changes)
      worker.refresh_sections_in_course
    end

    # Self-contained method suitable for running as a background job.
    def self.import_memberships(sis_course_id, sis_section_ids, enrollments_csv_filename)
      enrollments_rows = []
      users_rows = []
      known_users = []
      worker = Canvas::SiteMembershipsMaintainer.new(sis_course_id, sis_section_ids, enrollments_rows, users_rows, known_users, :batch_mode => true)
      worker.refresh_sections_in_course
      if enrollments_rows.empty?
        logger.warn("No memberships found for course site #{sis_course_id}")
        return
      end
      logger.warn("Importing #{enrollments_rows.size} memberships for #{known_users.size} users to course site #{sis_course_id}")
      enrollments_csv = worker.make_enrollments_csv(enrollments_csv_filename, enrollments_rows)
      response = Canvas::SisImport.new.import_enrollments(enrollments_csv)
      if response.blank?
        logger.error("Enrollments import to course site #{sis_course_id} failed")
      else
        logger.info("Successfully imported enrollments to course site #{sis_course_id}")
      end
    end

    def self.remove_memberships(sis_course_id, sis_section_ids, enrollments_csv_filename)
      enrollments_rows = []
      worker = Canvas::SiteMembershipsMaintainer.new(sis_course_id, sis_section_ids, enrollments_rows, [], [])
      sis_section_ids.each do |sis_section_id|
        canvas_section_id = "sis_section_id:#{sis_section_id}"
        existing_enrollment = Canvas::SectionEnrollments.new(section_id: canvas_section_id).list_enrollments
        existing_enrollment.each do |enrollment|
          worker.append_enrollment_deletion(sis_section_id, enrollment['role'], enrollment['user']['sis_user_id'])
        end
      end
      if enrollments_rows.empty?
        logger.warn("No memberships found for course site #{sis_course_id}, sections #{sis_section_ids}")
        return
      end
      logger.warn("Importing #{enrollments_rows.size} membership deletions to course site #{sis_course_id}")
      enrollments_csv = worker.make_enrollments_csv(enrollments_csv_filename, enrollments_rows)
      response = Canvas::SisImport.new.import_enrollments(enrollments_csv, '&override_sis_stickiness=true')
      if response.blank?
        logger.error("Enrollment deletion import to course site #{sis_course_id} failed")
      else
        logger.info("Successfully imported enrollment deletions to course site #{sis_course_id}")
      end
    end

    def initialize(sis_course_id, sis_section_ids, enrollments_csv_output, users_csv_output, known_users, options = {})
      default_options = { :batch_mode => false, :cached_enrollments_provider => nil, :sis_user_id_changes => {} }
      options.reverse_merge!(default_options)

      super()
      @sis_course_id = sis_course_id
      @sis_sections = filter_sections(sis_section_ids)
      @enrollments_csv_output = enrollments_csv_output
      @users_csv_output = users_csv_output
      @known_users = known_users
      @batch_mode = options[:batch_mode]
      @term_enrollments_csv_worker = options[:cached_enrollments_provider]
      @sis_user_id_changes = options[:sis_user_id_changes]
    end

    def filter_sections(sis_section_ids)
      campus_sections = sis_section_ids.collect do |sis_section_id|
        campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(sis_section_id)
        campus_section.merge!({'sis_section_id' => sis_section_id}) if campus_section.present?
        campus_section
      end
      campus_sections.select {|sec| sec.present? }
    end

    def sis_section_ids
      @sis_sections.collect {|section| section['sis_section_id']}
    end

    def refresh_sections_in_course
      logger.debug("Refreshing sections: #{sis_section_ids.to_sentence}")
      section_to_instructor_role = instructor_role_for_sections(@sis_sections)
      @sis_sections.each do |sis_section|
        sis_section_id = sis_section['sis_section_id']
        if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(sis_section_id))
          logger.debug("Refreshing section: #{sis_section_id}")
          instructor_role = section_to_instructor_role[campus_section]
          logger.debug("Instructor role detected for section: #{instructor_role}")
          canvas_section_id = "sis_section_id:#{sis_section_id}"
          refresh_enrollments_in_section(campus_section, sis_section_id, instructor_role, canvas_section_id)
        end
      end
    end

    def canvas_section_enrollments(canvas_sis_section_id)
      # So far as CSV generation is concerned, ignoring current memberships is equivalent to not having any current
      # memberships.
      if @batch_mode
        {}
      else
        if @term_enrollments_csv_worker
          canvas_sis_section_id.gsub!(/sis_section_id:/, '')
          logger.warn("Obtaining cached enrollments for #{canvas_sis_section_id}")
          canvas_section_enrollments = @term_enrollments_csv_worker.cached_canvas_section_enrollments(canvas_sis_section_id)
        else
          canvas_section_enrollments = Canvas::SectionEnrollments.new(section_id: canvas_sis_section_id).list_enrollments
        end
        canvas_section_enrollments.group_by {|e| e['user']['login_id']}
      end
    end

    def refresh_enrollments_in_section(campus_section, section_id, teacher_role, canvas_section_id)
      canvas_enrollments = canvas_section_enrollments(canvas_section_id)
      refresh_students_in_section(campus_section, section_id, canvas_enrollments)
      refresh_teachers_in_section(campus_section, section_id, teacher_role, canvas_enrollments)
      # Handle enrollments remaining in Canvas enrollment list
      logger.debug("Deleting remaining enrollments for Section ID #{section_id} - count: #{canvas_enrollments.count}")
      canvas_enrollments.each { |uid, remaining_enrollments| handle_missing_enrollments(uid, section_id, remaining_enrollments) }
    end

    def refresh_students_in_section(campus_section, section_id, canvas_section_enrollments)
      logger.debug("Refreshing students in section: #{section_id}")
      campus_data_rows = CampusOracle::Queries.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      logger.debug("#{campus_data_rows.count} student enrollments found for #{section_id}")
      campus_data_rows.each do |campus_data_row|
        next unless (canvas_api_role = ENROLL_STATUS_TO_CANVAS_API_ROLE[campus_data_row['enroll_status']])
        update_section_enrollment_from_campus(canvas_api_role, section_id, campus_data_row, canvas_section_enrollments)
      end
    end

    def refresh_teachers_in_section(campus_section, section_id, teacher_role, canvas_section_enrollments)
      logger.debug("Refreshing teachers in section: #{section_id}")
      canvas_api_role = CANVAS_SIS_ROLE_TO_CANVAS_API_ROLE[teacher_role]
      campus_data_rows = CampusOracle::Queries.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      logger.debug("#{campus_data_rows.count} instructor enrollments found for #{section_id}")
      campus_data_rows.each do |campus_data_row|
        update_section_enrollment_from_campus(canvas_api_role, section_id, campus_data_row, canvas_section_enrollments)
      end
    end

    def update_section_enrollment_from_campus(canvas_api_role, sis_section_id, campus_data_row, old_canvas_enrollments)
      login_uid = campus_data_row['ldap_uid'].to_s
      # Note: old_canvas_enrollments may originate from Canvas::TermEnrollmentsCsv
      # Make sure to update this class to include fields this logic depends on from the Canvas Enrollments API
      if (user_enrollments = old_canvas_enrollments[login_uid])
        logger.debug("#{user_enrollments.count} Enrollments found for UID #{login_uid}")
        # If the user already has the same role, remove the old enrollment from the cleanup list.
        if (matching_enrollment = user_enrollments.select{|e| e['role'] == canvas_api_role}.first)
          logger.debug("Matching enrollment found for UID #{login_uid} in role #{canvas_api_role}")
          sis_imported = matching_enrollment['sis_import_id'].present?
          user_enrollments.delete(matching_enrollment)
          # If the user's membership was due to an earlier SIS import, no action is needed.
          return if sis_imported
          # But if the user was manually added in this role, fall through and give Canvas a chance to convert the
          # membership stickiness from manual to SIS import.
        end
      else
        logger.debug("Adding UID #{login_uid} as new user")
        add_user_if_new(campus_data_row)
      end
      logger.debug("Adding UID #{login_uid} to SIS Section: #{sis_section_id} as role: #{canvas_api_role}")
      @enrollments_csv_output << {
        'course_id' => @sis_course_id,
        'user_id' => derive_sis_user_id(campus_data_row),
        'role' => api_role_to_csv_role(canvas_api_role),
        'section_id' => sis_section_id,
        'status' => 'active'
      }
    end

    def handle_missing_enrollments(uid, section_id, remaining_enrollments)
      remaining_enrollments.each do |enrollment|
        # Only look at enrollments which are active and were due to an SIS import.
        if enrollment['sis_import_id'].present? && enrollment['enrollment_state'] == 'active'
          logger.info "No campus record for Canvas enrollment in Course ID: #{enrollment['course_id']}, Section ID: #{enrollment['course_section_id']} for user #{uid} with role #{enrollment['role']}"
          sis_user_id = enrollment['user']['sis_user_id'] unless sis_user_id = @sis_user_id_changes["sis_login_id:#{uid}"]
          append_enrollment_deletion(section_id, enrollment['role'], sis_user_id)
        end
      end
    end

    def add_user_if_new(campus_data_row)
      uid = campus_data_row['ldap_uid']
      unless @known_users.include?(uid)
        @users_csv_output << canvas_user_from_campus_row(campus_data_row)
        @known_users << uid
      end
    end

    # For certain built-in enrollment roles, the Canvas enrollments API shows the
    # enrollment-type category (e.g., "StudentEnrollment") in place of the CSV-import-friendly
    # role (e.g., "student"). This is probably a bug, but we need to deal with it.
    # For customized enrollment roles, the "role" shown in the API is the same as used
    # in CSV imports.
    def api_role_to_csv_role(canvas_role)
      CANVAS_API_ROLE_TO_CANVAS_SIS_ROLE[canvas_role] || canvas_role
    end

    # Appends enrollment record for deletion
    def append_enrollment_deletion(section_id, api_role, sis_user_id)
      @enrollments_csv_output << {
        'course_id' => @sis_course_id,
        'user_id' => sis_user_id,
        'role' => api_role_to_csv_role(api_role),
        'section_id' => section_id,
        'status' => 'deleted'
      }
    end

    # If the bCourses site includes a mix of primary and secondary sections, then only primary section
    # instructors should be given the "teacher" role. However, it's important that *someone* play the
    # "teacher" role, and so if no primary sections are included, secondary-section instructors should
    # receive it.
    def instructor_role_for_sections(campus_sections)
      # Our campus data query for sections specifies CCNs in a specific term.
      # At this level of code, we're working section-by-section and can't guarantee that all sections
      # are in the same term. In real life, we expect them to be, but ensuring that and throwing an
      # error when terms vary would be about as much work as dealing with them. Start by grouping
      # CCNs by term.
      terms_to_sections = campus_sections.group_by {|sec| sec.slice(:term_yr, :term_cd)}
      if terms_to_sections.size > 1
        logger.warn("Multiple terms in course site #{@sis_course_id}!")
      end

      # This will hold a map whose keys are term_yr/term_cd/ccn hashes and whose values are the role
      # for instructors of that section.
      sections_map = {}

      # For each term, ask campus data sources for the section types (primary or secondary).
      # Since the list we get back from campus data may be in a different order from our starting
      # list of sections, or may be missing some sections, we turn the result into a new list
      # of term_yr/term_cd/ccn hashes.
      terms_to_sections.each do |term, sections|
        ccns = sections.collect {|sec| sec[:ccn]}
        data_rows = CampusOracle::Queries.get_sections_from_ccns(term[:term_yr], term[:term_cd], ccns)
        data_rows.each do |row|
          sec = term.merge(ccn: sprintf('%05d', row['course_cntl_num'].to_i))
          sections_map[sec] = row['primary_secondary_cd']
        end
      end
      # Now see if the course site's sections are of more than one section type. That will determine
      # what role is given to secondary-section instructors.
      section_types = sections_map.values.uniq
      secondary_section_role = section_types.size > 1 ? 'ta' : 'teacher'

      # Project leadership has expressed curiosity about this.
      if section_types == ['S']
        logger.info("Course site #{@sis_course_id} contains only secondary sections")
      end

      # Finalize the section-to-instructor-role hash.
      sections_map.each_key do |sec|
        sections_map[sec] = (sections_map[sec] == 'P') ? 'teacher' : secondary_section_role
      end
      sections_map
    end

  end
end
