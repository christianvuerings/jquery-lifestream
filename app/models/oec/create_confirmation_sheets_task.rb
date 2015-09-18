module Oec
  class CreateConfirmationSheetsTask < Task

    include Validator

    def run_internal
      term_folder = @remote_drive.find_first_matching_item @term_code
      imports_folder = @remote_drive.find_first_matching_item('imports', term_folder)
      most_recent_import = @remote_drive.find_folders(imports_folder.id).sort_by(&:title).last
      raise RuntimeError, "No SIS imports found for term #{@term_code}" unless most_recent_import

      confirmation_sheets = confirmations_from_imports most_recent_import
      if valid?
        departments_folder = @remote_drive.find_first_matching_item('departments', term_folder)
        raise RuntimeError, "No departments folder found for term #{@term_code}" unless departments_folder

        confirmation_sheets.each do |dept_name, confirmation_sheet|
          department_folder = find_or_create_folder(dept_name, departments_folder)
          export_sheet(confirmation_sheet, department_folder)
        end
      else
        log :error, 'Validation failed! Confirmation sheets will not be created.'
        log_validation_errors
      end
    end

    def confirmations_from_imports(imports)
      confirmation_sheets = {}
      Oec::CourseCode.by_dept_code(@course_code_filter).keys.each do |dept_code|
        dept_name = Berkeley::Departments.get(dept_code, concise: true)
        unless (dept_import_sheet = @remote_drive.find_first_matching_item(dept_name, imports))
          log :warn, "No sheet found for #{dept_name} in import folder '#{imports.title}'; skipping confirmation sheet creation."
          next
        end
        sis_import_sheet = Oec::SisImportSheet.from_csv @remote_drive.export_csv(dept_import_sheet)
        confirmation_sheets[dept_name] = Oec::CourseConfirmation.new
        sis_import_sheet.each do |row|
          validate_and_add(confirmation_sheets[dept_name], row, %w(COURSE_ID LDAP_UID))
        end
      end
      confirmation_sheets
    end

  end
end
