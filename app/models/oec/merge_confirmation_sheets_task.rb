module Oec
  class MergeConfirmationSheetsTask < Task

    include Validator

    def run_internal
      term_folder = @remote_drive.find_first_matching_item @term_code
      imports_folder = @remote_drive.find_first_matching_item('imports', term_folder)
      most_recent_import = @remote_drive.find_folders(imports_folder.id).sort_by(&:title).last
      raise RuntimeError, "No SIS imports found for term #{@term_code}" unless most_recent_import

      departments_folder = @remote_drive.find_first_matching_item('departments', term_folder)
      raise RuntimeError, "No departments folder found for term #{@term_code}" unless departments_folder

      supplemental_sources = @remote_drive.find_first_matching_item('supplemental_sources', term_folder)
      supervisors_sheet = @remote_drive.find_first_matching_item('supervisors', supplemental_sources)
      raise RuntimeError, "No supervisor sheet found in supplemental_sources for term #{@term_code}" unless supervisors_sheet

      supervisors = Oec::Supervisors.from_csv @remote_drive.export_csv(supervisors_sheet)

      merged_course_confirmations = Oec::SisImportSheet.new(export_name: 'Merged course confirmations')
      merged_supervisor_confirmations = Oec::Supervisors.new(export_name: 'Merged supervisor confirmations')

      @remote_drive.find_folders(departments_folder.id).each do |department_subfolder|
        course_confirmation_sheet = find_or_error('Courses', department_subfolder)
        supervisor_confirmation_sheet = find_or_error('Report Viewers', department_subfolder)
        sis_import_sheet = find_or_error(department_subfolder.title, most_recent_import)

        course_confirmation = Oec::CourseConfirmation.from_csv @remote_drive.export_csv(course_confirmation_sheet)
        supervisor_confirmation = Oec::SupervisorConfirmation.from_csv @remote_drive.export_csv(supervisor_confirmation_sheet)
        sis_import = Oec::SisImportSheet.from_csv @remote_drive.export_csv(sis_import_sheet)

        course_confirmation.each do |course_confirmation_row|
          next unless course_confirmation_row['EVALUATE'] && course_confirmation_row['EVALUATE'].casecmp('Y') == 0
          validate('Merged course confirmations', "#{course_confirmation_row['COURSE_ID']}-#{course_confirmation_row['LDAP_UID']}") do |errors|
            sis_import_rows = sis_import.select { |row| row['LDAP_UID'] == course_confirmation_row['LDAP_UID'] && row['COURSE_ID'] == course_confirmation_row['COURSE_ID']  }
            if sis_import_rows.none?
              errors.add 'No SIS import row found matching confirmation row'
            elsif sis_import_rows.count > 1
              errors.add 'Multiple SIS import rows found matching confirmation row'
            else
              merged_row = sis_import_rows.first.merge course_confirmation_row
              validate_and_add(merged_course_confirmations, merged_row, %w(COURSE_ID LDAP_UID))
            end
          end
        end

        supervisor_confirmation.each do |supervisor_confirmation_row|
          validate('Merged supervisor confirmations', supervisor_confirmation_row['LDAP_UID']) do |errors|
            supervisor_rows = supervisors.select { |row| row['LDAP_UID'] == supervisor_confirmation_row['LDAP_UID']}
            if supervisor_rows.none?
              errors.add 'No supervisors row found matching confirmation row'
            elsif supervisor_rows.count > 1
              errors.add 'Multiple supervisor rows found matching confirmation row'
            else
              merged_row = supervisor_rows.first.merge supervisor_confirmation_row
              validate_and_add(merged_supervisor_confirmations, merged_row, %w(LDAP_UID))
            end
          end
        end
      end

      if valid?
        export_sheet(merged_course_confirmations, departments_folder)
        export_sheet(merged_supervisor_confirmations, departments_folder)
      else
        log :error, 'Validation failed! Confirmation sheets will not be merged.'
        log_validation_errors
      end
    end

    def find_or_error(title, folder)
      @remote_drive.find_first_matching_item(title, folder) || (raise RuntimeError "Could not find sheet '#{title}' in folder '#{folder.title}'")
    end

  end
end
