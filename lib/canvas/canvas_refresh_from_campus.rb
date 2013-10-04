require 'csv'

class CanvasRefreshFromCampus < CanvasCsv
  include ClassLogger

  def full_refresh
    csv_files = make_csv_files
    if csv_files
      import_csv_files(csv_files[:users], csv_files[:enrollments])
    end
  end

  def make_csv_files
    raw_users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users-with-duplicates.csv"
    users_csv = make_users_csv(raw_users_csv_filename)
    term_ids = CanvasProxy.current_sis_term_ids
    term_enrollment_csv_files = {}
    term_ids.each do |term_id|
      # Prevent collisions between the SIS_ID code and the filesystem.
      sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
      csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{sanitized_term_id}-enrollments.csv"
      enrollments_csv = make_enrollments_csv(csv_filename)
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
    if import_proxy.import_users(users_csv_filename)
      logger.warn("User import succeeded")
      term_enrollment_csv_files.each do |term_id, csv_filename|
        if import_proxy.import_all_term_enrollments(term_id, csv_filename)
            logger.warn("Enrollment import succeeded")
        end
      end
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
