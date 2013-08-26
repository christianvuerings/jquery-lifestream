require 'csv'

class CanvasRefreshFromCampus < CanvasMaintenance

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

  def full_refresh
    csv_files = make_csv_files
    if csv_files
      import_csv_files(csv_files[:users], csv_files[:enrollments])
    end
  end

  def make_csv_files
    raw_users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users-with-duplicates.csv"
    users_csv = CSV.open(
        raw_users_csv_filename, 'wb',
        {
            headers: 'user_id,login_id,first_name,last_name,email,status',
            write_headers: true
        }
    )
    term_ids = CanvasProxy.current_sis_term_ids
    term_enrollment_csv_files = {}
    term_ids.each do |term_id|
      # Prevent collisions between the SIS_ID code and the filesystem.
      sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
      csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{sanitized_term_id}-enrollments.csv"
      enrollments_csv = CSV.open(
          csv_filename, 'wb',
          {
              headers: 'course_id,user_id,role,section_id,status,associated_user_id',
              write_headers: true
          }
      )
      sections = get_all_sis_sections_for_term(term_id)
      sections.each do |section|
        accumulate_section_enrollments(section, enrollments_csv, users_csv)
        accumulate_section_instructors(section, enrollments_csv, users_csv)
      end
      enrollments_csv.close
      if File.zero?(csv_filename)
        logger.warn("No Canvas enrollment records for #{term_id} - SKIPPING REFRESH")
      else
        total_enrollments = CSV.read(csv_filename, {headers: true}).length
        logger.warn("Will refresh #{total_enrollments} Canvas enrollment records for #{term_id}")
        term_enrollment_csv_files[term_id] = csv_filename
      end
    end
    users_csv.close
    users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users.csv"
    users_count = csv_without_duplications(raw_users_csv_filename, users_csv_filename)
    if users_count == 0
      logger.warn("No Canvas user account records for enrollments - SKIPPING REFRESH")
      nil
    else
      logger.warn("Will refresh #{users_count} Canvas user records")
      { users: users_csv_filename, enrollments: term_enrollment_csv_files }
    end
  end

  # Uploading a single zipped archive containing both users and enrollments would be safer and more efficient.
  # However, a batch update can only be done for one term. If we decide to limit Canvas refreshes
  # to a single term, then we should change this code.
  def import_csv_files(users_csv_filename, term_enrollment_csv_files)
    import_proxy = CanvasSisImportProxy.new
    response = import_proxy.post_users(users_csv_filename)
    if response && response.status == 200
      json = JSON.parse(response.body)
      import_id = json["id"]
      import_status = import_proxy.import_status(import_id)
      import_success = import_proxy.import_was_successful?(import_status)

      if import_success
        logger.warn("User import succeeded")
        term_enrollment_csv_files.each do |term_id, csv_filename|
          enrollment_response = import_proxy.post_enrollments(term_id, csv_filename)
          if enrollment_response && enrollment_response.status == 200
            enrollment_json = JSON.parse(enrollment_response.body)
            enrollment_import_id = enrollment_json["id"]
            enrollment_import_status = import_proxy.import_status(enrollment_import_id)
            enrollment_import_success = import_proxy.import_was_successful?(enrollment_import_status)
            if enrollment_import_success
              logger.warn("Enrollment import succeeded")
            else
              logger.error("Enrollment import failed or incompletely processed. Import status: #{enrollment_import_status}")
            end
          else
            logger.error("Unable to POST enrollment CSV #{csv_filename} to Canvas")
          end
        end
      else
        logger.error("User import failed or incompletely processed; skipping enrollments. Import status: #{import_status}")
      end
    else
      logger.error("Unable to POST users CSV #{users_csv_filename} to Canvas; skipping enrollments. Response = #{response}")
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
  end

  def get_all_sis_sections_for_term(term_id)
    sections = []
    report_proxy = CanvasSectionsReportProxy.new
    csv = report_proxy.get_csv(term_id)
    if (csv)
      update_proxy = CanvasSisImportProxy.new
      csv.each do |row|
        if (sis_section_id = row['section_id'])
          sis_course_id = row['course_id']
          if (sis_course_id.blank?)
            logger.warn("Canvas section has SIS ID but course does not: #{row}")
          else
            sections.push({
                section_id: sis_section_id,
                course_id: sis_course_id,
                term_id: term_id
                          })
          end
        end
      end
    end
    sections
  end

end