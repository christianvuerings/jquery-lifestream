module Canvas
  require 'csv'

  class RefreshAllCampusData < Csv
    include ClassLogger
    attr_accessor :users_csv_filename
    attr_accessor :term_to_memberships_csv_filename

    def initialize(batch_or_incremental)
      super()
      @users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users-#{batch_or_incremental}.csv"
      @term_to_memberships_csv_filename = {}
      case batch_or_incremental
        when 'batch'
          @enrollments_maintainer = Canvas::BatchEnrollments.new
        when 'incremental'
          @enrollments_maintainer = Canvas::IncrementalEnrollments.new
        else
          raise ArgumentError, "Unknown refresh type #{batch_or_incremental}"
      end
      term_ids = Canvas::Proxy.current_sis_term_ids
      term_ids.each do |term_id|
        # Prevent collisions between the SIS_ID code and the filesystem.
        sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
        csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{sanitized_term_id}-enrollments-#{batch_or_incremental}.csv"
        @term_to_memberships_csv_filename[term_id] = csv_filename
      end
    end

    def run
      make_csv_files
      import_csv_files
    end

    def make_csv_files
      users_csv = make_users_csv(@users_csv_filename)
      known_uids = []
      Canvas::MaintainUsers.new.refresh_existing_user_accounts(known_uids, users_csv)
      original_user_count = known_uids.length
      @term_to_memberships_csv_filename.each do |term, csv_filename|
        enrollments_csv = make_enrollments_csv(csv_filename)
        refresh_existing_term_sections(term, enrollments_csv, known_uids, users_csv)
        enrollments_csv.close
        enrollments_count = csv_count(csv_filename)
        logger.warn("Will upload #{enrollments_count} Canvas enrollment records for #{term}")
        @term_to_memberships_csv_filename[term] = nil if enrollments_count == 0
      end
      new_user_count = known_uids.length - original_user_count
      users_csv.close
      updated_user_count = csv_count(@users_csv_filename) - new_user_count
      logger.warn("Will upload #{updated_user_count} changed accounts for #{original_user_count} existing users")
      logger.warn("Will upload #{new_user_count} new user accounts")
      @users_csv_filename = nil if (updated_user_count + new_user_count) == 0
    end

    # Uploading a single zipped archive containing both users and enrollments would be safer and more efficient.
    # However, a batch update can only be done for one term. If we decide to limit Canvas refreshes
    # to a single term, then we should change this code.
    def import_csv_files
      import_proxy = Canvas::SisImport.new
      if @users_csv_filename.blank? || import_proxy.import_users(@users_csv_filename)
        logger.warn("User import succeeded")
        @term_to_memberships_csv_filename.each do |term_id, csv_filename|
          if csv_filename.present?
            case @batch_or_incremental
              when 'batch'
                import_proxy.import_batch_term_enrollments(term_id, csv_filename)
              when 'incremental'
                import_proxy.import_all_term_enrollments(term_id, csv_filename)
            end
          end
          logger.warn("Enrollment import for #{term_id} succeeded")
        end
      end
    end

    def csv_count(csv_filename)
      CSV.read(csv_filename, {headers: true}).length
    end

    def refresh_existing_term_sections(term, enrollments_csv, known_users, users_csv)
      canvas_sections_csv = Canvas::SectionsReport.new.get_csv(term)
      return if canvas_sections_csv.empty?
      # Group Canvas sections CSV by course site. (CSV does not support "sort_by values_at"
      # or comparisons to nil.)
      canvas_sections_csv = canvas_sections_csv.sort do |a, b|
        [(a['course_id'] || ''), (a['section_id'] || '')] <=> [(b['course_id'] || ''), (b['section_id'] || '')]
      end
      working_course_id = nil
      working_course_section_rows = []
      working_campus_sections = []
      canvas_sections_csv.each do |canvas_section|
        if (course_id = canvas_section['course_id']) &&  (section_id = canvas_section['section_id'])
          if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(section_id))
            if course_id != working_course_id
              if working_course_id.present?
                refresh_sections_in_course(working_course_id, working_course_section_rows, working_campus_sections,
                  enrollments_csv, known_users, users_csv)
              end
              working_course_id = course_id
              working_course_section_rows = []
              working_campus_sections = []
            end
            working_course_section_rows << canvas_section
            working_campus_sections << campus_section
          end
        end
      end
      if working_course_id.present?
        refresh_sections_in_course(working_course_id, working_course_section_rows, working_campus_sections,
          enrollments_csv, known_users, users_csv)
      end
    end

    def refresh_sections_in_course(course_id, course_section_rows, campus_sections, enrollments_csv, known_users, users_csv)
      section_to_instructor_role = instructor_role_for_sections(campus_sections, course_id)
      course_section_rows.each do |canvas_section|
        section_id = canvas_section['section_id']
        campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(section_id)
        instructor_role = section_to_instructor_role[campus_section]
        @enrollments_maintainer.refresh_enrollments_in_section(campus_section, course_id, section_id,
          instructor_role, canvas_section['canvas_section_id'], enrollments_csv, known_users, users_csv)
      end
    end

    # If the bCourses site includes a mix of primary and secondary sections, then only primary section
    # instructors should be given the "teacher" role. However, it's important that *someone* play the
    # "teacher" role, and so if no primary sections are included, secondary-section instructors should
    # receive it.
    def instructor_role_for_sections(campus_sections, course_id)
      sections_map = {}
      terms_to_ccns = {}
      campus_sections.each do |sec|
        term = sec.slice(:term_yr, :term_cd)
        terms_to_ccns[term] ||= []
        terms_to_ccns[term] << sec[:ccn]
      end
      terms_to_ccns.each do |term, ccns|
        data_rows = CampusOracle::Queries.get_sections_from_ccns(term[:term_yr], term[:term_cd], ccns)
        data_rows.each do |row|
          sec = term.merge(ccn: row['course_cntl_num'].to_s)
          sections_map[sec] = row['primary_secondary_cd']
        end
      end
      section_types = sections_map.values
      secondary_section_role = section_types.include?('P') && section_types.include?('S') ? 'ta' : 'teacher'

      # Project leadership has expressed curiosity about this.
      if section_types.present? && !section_types.include?('P')
        logger.info("Course site #{course_id} contains only secondary sections")
      end

      sections_map.each_key do |sec|
        sections_map[sec] = (sections_map[sec] == 'P') ? 'teacher' : secondary_section_role
      end
      sections_map
    end

  end
end
