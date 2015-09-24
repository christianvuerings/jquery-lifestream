module Oec
  class CreateConfirmationSheetsTask < Task

    include Validator

    def run_internal
      term_folder = @remote_drive.find_first_matching_item @term_code
      imports_folder = @remote_drive.find_first_matching_item('imports', term_folder)
      most_recent_import = @remote_drive.find_folders(imports_folder.id).sort_by(&:title).last
      raise RuntimeError, "No SIS imports found for term #{@term_code}" unless most_recent_import

      supplemental_sources = @remote_drive.find_first_matching_item('supplemental_sources', term_folder)
      supervisors_sheet = @remote_drive.find_first_matching_item('supervisors', supplemental_sources)
      raise RuntimeError, "No supervisor sheet found in supplemental_sources for term #{@term_code}" unless supervisors_sheet
      supervisors = Oec::Supervisors.from_csv @remote_drive.export_csv(supervisors_sheet)

      confirmations = generate_confirmations(most_recent_import, supervisors)

      if valid?
        departments_folder = @remote_drive.find_first_matching_item('departments', term_folder)
        raise RuntimeError, "No departments folder found for term #{@term_code}" unless departments_folder
        confirmations.each do |dept_name, dept_confirmations|
          department_folder = find_or_create_folder(dept_name, departments_folder)
          export_sheet(dept_confirmations[:courses], department_folder)
          export_sheet(dept_confirmations[:supervisors], department_folder)
        end
      else
        log :error, 'Validation failed! Confirmation sheets will not be created.'
        log_validation_errors
      end
    end

    def generate_confirmations(imports, supervisors)
      confirmations = {}
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        dept_name = Berkeley::Departments.get(dept_code, concise: true)
        unless (dept_import_sheet = @remote_drive.find_first_matching_item(dept_name, imports))
          log :warn, "No sheet found for #{dept_name} in import folder '#{imports.title}'; skipping confirmation sheet creation."
          next
        end
        confirmations[dept_name] = {
          courses: generate_course_confirmation(dept_import_sheet),
          supervisors: generate_supervisor_confirmation(supervisors, course_codes)
        }
      end
      confirmations
    end

    def generate_course_confirmation(dept_import_sheet)
      course_confirmation = Oec::CourseConfirmation.new
      sis_import_sheet = Oec::SisImportSheet.from_csv @remote_drive.export_csv(dept_import_sheet)
      sis_import_sheet.each do |row|
        validate_and_add(course_confirmation, row, %w(COURSE_ID LDAP_UID))
      end
      course_confirmation
    end

    def generate_supervisor_confirmation(supervisors, course_codes)
      supervisor_confirmation = Oec::SupervisorConfirmation.new
      course_codes.each do |course_code|
        supervisors.matching_dept_name(course_code.dept_name).each do |supervisor_row|
          validate_and_add(supervisor_confirmation, supervisor_row, %w(LDAP_UID))
        end
      end
      supervisor_confirmation
    end

  end
end
