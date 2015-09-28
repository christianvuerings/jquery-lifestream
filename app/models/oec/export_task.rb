module Oec
  class ExportTask < Task

    include Validator

    def run_internal
      merged_course_confirmations = @remote_drive.find_nested [@term_code, 'departments', 'Merged course confirmations']
      merged_course_confirmations_csv = merged_course_confirmations && @remote_drive.export_csv(merged_course_confirmations)
      raise RuntimeError, 'No merged course confirmation sheet found' unless merged_course_confirmations_csv

      instructors = Oec::Instructors.new
      course_instructors = Oec::CourseInstructors.new
      courses = Oec::Courses.new
      students = Oec::Students.new
      course_students = Oec::CourseStudents.new

      merged_supervisor_confirmations = @remote_drive.find_nested [@term_code, 'departments', 'Merged supervisor confirmations']
      merged_supervisor_confirmations_csv = merged_supervisor_confirmations && @remote_drive.export_csv(merged_supervisor_confirmations)
      raise RuntimeError, 'No merged supervisor confirmation sheet found' unless merged_supervisor_confirmations_csv

      supervisors = Oec::Supervisors.from_csv(merged_supervisor_confirmations_csv)
      course_supervisors = Oec::CourseSupervisors.new

      ccns = Set.new
      suffixed_ccns = {}

      Oec::SisImportSheet.from_csv(merged_course_confirmations_csv, dept_code: nil).each do |confirmation|
        next unless confirmation['EVALUATE'] && confirmation['EVALUATE'].casecmp('Y') == 0

        validate('courses', confirmation['COURSE_ID']) do |errors|
          errors.add('Blank instructor LDAP_UID') && next if confirmation['LDAP_UID'].blank?
          validate_and_add(courses, confirmation, %w(COURSE_ID))
        end

        if confirmation['LDAP_UID'].present?
          validate_and_add(instructors, confirmation, %w(LDAP_UID))
          validate_and_add(course_instructors, confirmation, %w(LDAP_UID COURSE_ID))
        end

        if confirmation['DEPT_FORM'].present?
          dept_supervisors = supervisors.matching_dept_name(confirmation['DEPT_FORM'])
          validate('courses', confirmation['COURSE_ID']) do |errors|
            errors.add "No supervisors found for DEPT_FORM #{confirmation['DEPT_FORM']}" if dept_supervisors.none?
            dept_supervisors.each do |supervisor|
              course_supervisor_row = {
                'COURSE_ID' => confirmation['COURSE_ID'],
                'LDAP_UID' => supervisor['LDAP_UID'],
                'DEPT_NAME' => confirmation['DEPT_FORM']
              }
              validate_and_add(course_supervisors, course_supervisor_row, %w(LDAP_UID COURSE_ID))
            end
          end
        end

        next unless (ccn = confirmation['COURSE_ID'].split('-')[2])
        ccn, suffix = ccn.split('_')
        if suffix
          suffixed_ccns[ccn] ||= Set.new
          suffixed_ccns[ccn] << suffix
        else
          ccns << ccn
        end
      end

      Oec::Queries.students_for_cntl_nums(@term_code, ccns).each do |student_row|
        validate_and_add(students, Oec::Worksheet.capitalize_keys(student_row), %w(LDAP_UID))
      end

      log :warn, "Getting students for #{ccns.length} non-suffixed CCNs" unless ccns.none?
      Oec::Queries.enrollments_for_cntl_nums(@term_code, ccns).each do |enrollment_row|
        validate_and_add(course_students, Oec::Worksheet.capitalize_keys(enrollment_row), %w(LDAP_UID COURSE_ID))
      end

      # Course IDs with suffixes need a little extra wrangling to match up with Oracle queries.
      log :warn, "Getting students for #{suffixed_ccns.length} suffixed CCNs" unless suffixed_ccns.none?
      Oec::Queries.enrollments_for_cntl_nums(@term_code, suffixed_ccns.keys).each do |enrollment_row|
        ccn = enrollment_row['course_id'].split('-')[2].split('_')[0]
        suffixed_ccns[ccn].each do |suffix|
          capitalized_row = Oec::Worksheet.capitalize_keys enrollment_row
          capitalized_row['COURSE_ID'] = "#{capitalized_row['COURSE_ID']}_#{suffix}"
          validate_and_add(course_students, capitalized_row, %w(LDAP_UID COURSE_ID))
        end
      end

      if valid?
        exports_now = find_or_create_now_subfolder 'exports'
        [instructors, course_instructors, courses, students, course_students, supervisors, course_supervisors].each do |sheet|
          export_sheet(sheet, exports_now)
        end
      else
        log :error, 'Validation failed! No sheets will be exported.'
        log_validation_errors
      end
    end

  end
end
