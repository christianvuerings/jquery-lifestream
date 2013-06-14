require 'csv'

class CanvasRefreshFromCampus
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
    user_ids = Set.new
    term_ids = CanvasProxy.current_sis_term_ids
    term_enrollment_csv_files = {}
    term_ids.each do |term_id|
      # Prevent collisions between the SIS_ID code and the filesystem.
      sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
      csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{sanitized_term_id}-enrollments.csv"
      enrollments_csv = CSV.open(csv_filename, 'wb',
                                 {
                                     headers: 'course_id,user_id,role,section_id,status,associated_user_id',
                                     write_headers: true
                                 }
      )
      sections = get_all_sis_sections_for_term(term_id)
      sections.each do |section|
        accumulate_section_enrollments(section, enrollments_csv, user_ids)
        accumulate_section_instructors(section, enrollments_csv, user_ids)
      end
      enrollments_csv.close
      if File.zero?(csv_filename)
        Rails.logger.warn("No Canvas enrollment records for #{term_id} - SKIPPING REFRESH")
      else
        total_enrollments = CSV.read(csv_filename, {headers: true}).length
        Rails.logger.info("Will refresh #{total_enrollments} Canvas enrollment records for #{term_id}")
        term_enrollment_csv_files[term_id] = csv_filename
      end
    end
    if user_ids.empty?
      Rails.logger.warn("No Canvas user account records for enrollments - SKIPPING REFRESH")
      nil
    else
      Rails.logger.info("Will refresh #{user_ids.length} Canvas user records")
      users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users.csv"
      users_csv = CSV.open(users_csv_filename, 'wb',
                           {
                               headers: 'user_id,login_id,first_name,last_name,email,status',
                               write_headers: true
                           }
      )
      accumulate_user_data(user_ids, users_csv)
      users_csv.close
      { users: users_csv_filename, enrollments: term_enrollment_csv_files }
    end
  end

  # Uploading a single zipped archive containing both users and enrollments would be safer and more efficient.
  # However, a batch update can only be done for one term. If we decide to limit Canvas refreshes
  # to a single term, then we should change this code.
  def import_csv_files(users_csv_filename, term_enrollment_csv_files)
    import_proxy = CanvasSisImportProxy.new
    response = import_proxy.post_users(users_csv_filename)
    if response
      term_enrollment_csv_files.each do |term_id, csv_filename|
        response = import_proxy.post_enrollments(term_id, csv_filename)
        if response.nil?
          Rails.logger.error("Unable to POST enrollment CSV #{csv_filename} to Canvas")
        end
      end
    else
      Rails.logger.error("Unable to POST users CSV #{users_csv_filename} to Canvas; skipping enrollments")
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
            'user_id' => row['ldap_uid'],
            'login_id' => row['ldap_uid'],
            'first_name' => row['first_name'],
            'last_name' => row['last_name'],
            'email' => row['email_address'],
            'status' => 'active'
        }
      end
    end
  end

  def accumulate_section_enrollments(section, total_enrollments, total_user_ids)
    section_id = section[:section_id]
    if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(section_id))
      section_enrollments = CampusData.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
      section_enrollments.each do |enr|
        uid = enr['ldap_uid']
        total_enrollments << {
            'course_id' => section[:course_id],
            'user_id' => uid,
            'role' => 'student',
            'section_id' => section_id,
            'status' => 'active'
        }
        total_user_ids << uid
      end
    else
      Rails.logger.warn("Badly formatted sis_section_id for Canvas section #{section}")
    end
  end

  def accumulate_section_instructors(section, total_enrollments, total_user_ids)
    section_id = section[:section_id]
    if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(section_id))
      section_instructors = CampusData.get_section_instructors(campus_section[:term_yr], campus_section[:term_cd], campus_section[:ccn])
      section_instructors.each do |ins|
        uid = ins['ldap_uid']
        total_enrollments << {
            'course_id' => section[:course_id],
            'user_id' => uid,
            'role' => 'teacher',
            'section_id' => section_id,
            'status' => 'active'
        }
        total_user_ids << uid
      end
    else
      Rails.logger.warn("Badly formatted sis_section_id for Canvas section #{section}")
    end
  end

  def get_all_sis_sections_for_term(term_id)
    sections = []
    report_proxy = CanvasAccountSectionsReportProxy.new
    csv = report_proxy.get_csv(term_id)
    if (csv)
      update_proxy = CanvasSisImportProxy.new
      csv.each do |row|
        if (sis_section_id = row['section_id'])
          sis_course_id = row['course_id']
          if (sis_course_id.blank?)
            Rails.logger.warn("Canvas section has SIS ID but course does not: #{row}")
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

  def repair_sis_ids_for_term(term_id)
    report_proxy = CanvasAccountSectionsReportProxy.new
    csv = report_proxy.get_csv(term_id)
    if (csv)
      update_proxy = CanvasSisImportProxy.new
      csv.each do |row|
        if (sis_section_id = row['section_id'])
          sis_course_id = row['course_id']
          if (sis_course_id.blank?)
            Rails.logger.warn("Canvas section has SIS ID but course does not: #{row}")
            response = update_proxy.generate_course_sis_id(row['canvas_course_id'])
            if response
              course_data = JSON.parse(response.body)
              sis_course_id = course_data['sis_course_id']
              Rails.logger.warn("Added SIS ID to Canvas course: #{course_data}")
            end
          end
        end
      end
    end
  end

end