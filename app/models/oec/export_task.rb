module Oec
  class ExportTask < Task

    def run_internal
      merged_course_confirmations = @remote_drive.find_nested [@term_code, 'departments', 'merged_course_confirmations']
      merged_course_confirmations_csv = merged_course_confirmations && @remote_drive.export_csv(merged_course_confirmations)
      raise RuntimeError, 'No merged course confirmation sheet found' unless merged_course_confirmations_csv

      instructors = Oec::Instructors.new
      course_instructors = Oec::CourseInstructors.new
      courses = Oec::Courses.new
      students = Oec::Students.new
      course_students = Oec::CourseStudents.new

      merged_supervisor_confirmations = @remote_drive.find_nested [@term_code, 'departments', 'merged_supervisor_confirmations']
      merged_supervisor_confirmations_csv = merged_supervisor_confirmations && @remote_drive.export_csv(merged_supervisor_confirmations)
      raise RuntimeError, 'No merged supervisor confirmation sheet found' unless merged_supervisor_confirmations_csv

      supervisors = Oec::Supervisors.from_csv(merged_supervisor_confirmations_csv)
      course_supervisors = Oec::CourseSupervisors.new

      ccns = Set.new
      suffixed_ccns = {}

      Oec::SisImportSheet.from_csv(merged_course_confirmations_csv, dept_code: nil).each do |locked_confirmation_row|
        add_checking_conflicts(courses, locked_confirmation_row, %w(COURSE_ID))
        add_checking_conflicts(course_instructors, locked_confirmation_row, %w(LDAP_UID COURSE_ID))
        add_checking_conflicts(instructors, locked_confirmation_row, %w(LDAP_UID))

        supervisors.matching_dept_name(locked_confirmation_row['DEPT_FORM']).each do |supervisor|
          course_supervisor_row = {
            'COURSE_ID' => locked_confirmation_row['COURSE_ID'],
            'LDAP_UID' => supervisor['LDAP_UID'],
            'DEPT_NAME' => locked_confirmation_row['DEPT_FORM']
          }
          add_checking_conflicts(course_supervisors, course_supervisor_row, %w(LDAP_UID COURSE_ID))
        end

        next unless (ccn = locked_confirmation_row['COURSE_ID'].split('-')[2])
        ccn, suffix = ccn.split('_')
        if suffix
          suffixed_ccns[ccn] ||= Set.new
          suffixed_ccns[ccn] << suffix
        else
          ccns << ccn
        end
      end

      Oec::Queries.students_for_cntl_nums(@term_code, ccns).each do |student_row|
        add_checking_conflicts(students, Oec::Worksheet.capitalize_keys(student_row), %w(LDAP_UID))
      end

      log :warn, "Getting students for #{ccns.length} non-suffixed CCNs" unless ccns.none?
      Oec::Queries.enrollments_for_cntl_nums(@term_code, ccns).each do |enrollment_row|
        add_checking_conflicts(course_students, Oec::Worksheet.capitalize_keys(enrollment_row), %w(LDAP_UID COURSE_ID))
      end

      # Any course ID suffixes must match in courses and course_students
      log :warn, "Getting students for #{suffixed_ccns.length} suffixed CCNs" unless suffixed_ccns.none?
      Oec::Queries.enrollments_for_cntl_nums(@term_code, suffixed_ccns.keys).each do |enrollment_row|
        ccn = enrollment_row['course_id'].split('-')[2].split('_')[0]
        suffixed_ccns[ccn].each do |suffix|
          capitalized_row = Oec::Worksheet.capitalize_keys enrollment_row
          capitalized_row['COURSE_ID'] = "#{capitalized_row['COURSE_ID']}_#{suffix}"
          add_checking_conflicts(course_students, capitalized_row, %w(LDAP_UID COURSE_ID))
        end
      end

      exports_today = find_or_create_today_subfolder 'exports'
      [instructors, course_instructors, courses, students, course_students, supervisors, course_supervisors].each do |sheet|
        export_sheet(sheet, exports_today)
      end
    end

    def add_checking_conflicts(sheet, row, key_columns)
      key = key_columns.map { |col| row[col] }.join('-')
      candidate_row = row.slice(*sheet.headers)
      if sheet[key] && (sheet[key] != candidate_row)
        raise RuntimeError, "Sheet '#{sheet.export_name}' has conflicting values for key '#{key}'; aborting export\n#{sheet[key]}\n#{candidate_row}"
      else
        sheet[key] ||= candidate_row
      end
    end

  end
end
