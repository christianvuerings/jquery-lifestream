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
        template = @remote_drive.find_first_matching_item('TEMPLATE', departments_folder)

        confirmations.each do |dept_name, dept_confirmations|
          if @remote_drive.find_first_matching_item(dept_name, departments_folder)
            log :warn, "File '#{dept_name}' exists in departments folder, will not create confirmation sheet"
            next
          end

          if @opts[:local_write]
            dept_confirmations[:courses].write_csv
            log :debug, "Exported to local file #{dept_confirmations[:courses].csv_export_path}"
            dept_confirmations[:supervisors].write_csv
            log :debug, "Exported to local file #{dept_confirmations[:supervisors].csv_export_path}"
          else
            if template && template.mime_type == 'application/vnd.google-apps.spreadsheet'
              log :debug, "Will copy new '#{dept_name}' confirmation sheet from template"
              dept_sheet = (template_copy = @remote_drive.copy_item(template.id, dept_name)) && @remote_drive.spreadsheet_by_id(template_copy.id)
              dept_worksheets = dept_sheet.worksheets
              courses_worksheet = dept_worksheets.find { |w| w.title == 'Courses' }
              raise RuntimeError, "Could not find worksheet 'Courses' in template copy '#{dept_sheet.title}'" unless courses_worksheet
              report_viewers_worksheet = dept_worksheets.find { |w| w.title == 'Report Viewers' }
              raise RuntimeError, "Could not find worksheet 'Report Viewers' in template copy '#{dept_sheet.title}'" unless report_viewers_worksheet
            else
              log :debug, "No template confirmation sheet found, will create blank '#{dept_name}' confirmation sheet"
              dept_sheet = @remote_drive.upload_to_spreadsheet(dept_name, '', StringIO.new(dept_confirmations[:courses].headers.join(',')), departments_folder.id)
              courses_worksheet = dept_sheet.worksheets.first
              report_viewers_worksheet = dept_sheet.add_worksheet('Report Viewers', 100, dept_confirmations[:supervisors].headers.count)
              dept_confirmations[:supervisors].headers.each_with_index { |header, i| report_viewers_worksheet[1, i+1] = header }
              report_viewers_worksheet.save
            end
            update_worksheet(courses_worksheet, dept_confirmations[:courses])
            update_worksheet(report_viewers_worksheet, dept_confirmations[:supervisors])
          end
        end
      else
        log :error, 'Validation failed! Confirmation sheets will not be created.'
        log_validation_errors
      end
    end

    def generate_confirmations(imports, supervisors)
      confirmations = {}
      import_items = @remote_drive.get_items_in_folder imports.id
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        dept_name = Berkeley::Departments.get(dept_code, concise: true)
        unless (dept_import_sheet = import_items.find { |f| f.title == dept_name })
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

    def update_worksheet(remote_sheet, local_sheet)
      headers = remote_sheet.rows.last
      offset = remote_sheet.rows.count + 1
      cell_updates = {}
      local_sheet.each_with_index do |local_sheet_row, y|
        headers.each_with_index { |header, x| cell_updates[[y+offset, x+1]] = local_sheet_row[header] }
      end
      begin
        @remote_drive.update_worksheet(remote_sheet, cell_updates)
        log :debug, "Exported confirmation data to '#{remote_sheet.title}' worksheet"
      rescue Errors::ProxyError => e
        log :error, "Export of confirmation data to '#{remote_sheet.title}' failed: #{e}"
      end
    end

  end
end
