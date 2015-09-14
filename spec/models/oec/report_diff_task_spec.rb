describe Oec::ReportDiffTask do

  context '#real', testext: true do
    let(:term_code) { '2015-D' }
    let(:dept_code) { 'PSTAT' }
    let(:dept_name) { Berkeley::Departments.get(dept_code, concise: true) }
    let(:tomorrow) { DateTime.tomorrow }
    let(:datetime) { tomorrow.strftime('%F') }
    let(:remote_drive) { Oec::RemoteDrive.new }

    context 'Department of Bioengineering diff', :order => :defined do
      before {
        # Generate import for tomorrow to avoid conflict with other testing
        task = Oec::SisImportTask.new(term_code: term_code, dept_codes: dept_code, date_time: tomorrow)
        task.run_internal
        # Grab the file we just generated
        expect(imports = remote_drive.find_nested([term_code, 'imports'])).to_not be_nil
        expect(@imports_subdir = remote_drive.find_first_matching_folder(datetime, imports)).to_not be_nil
        dept_name = Berkeley::Departments.get(dept_code, concise: true)
        import_file_array = remote_drive.spreadsheets_by_title(dept_name, parent_id: @imports_subdir.id)
        expect(import_file_array).to have(1).item
        # Copy import spreadsheet to location managed by dept for testing purposes.
        parent = remote_drive.find_nested [term_code, 'departments']
        dept_folder = remote_drive.check_conflicts_and_create_folder(dept_name, parent, on_conflict: :return_existing)
        remote_drive.copy_item_to_folder(import_file_array[0], dept_folder.id, 'Courses')
      }

      after {
        dept_file = remote_drive.find_nested [term_code, 'departments', dept_name]
        remote_drive.trash_item(dept_file, permanently_delete: true) if dept_file
        remote_drive.trash_item(@imports_subdir, permanently_delete: true)
        reports_subdir = remote_drive.find_nested [term_code, 'reports', datetime]
        remote_drive.trash_item(reports_subdir, permanently_delete: true) if reports_subdir
      }

      it 'should find department courses spreadsheet' do
        courses_spreadsheet = remote_drive.find_dept_courses_spreadsheet(term_code, dept_code)
        expect(courses_spreadsheet).to_not be_nil
      end

      it 'should report no diff' do
        task = Oec::ReportDiffTask.new(term_code: term_code, dept_codes: dept_code, date_time: tomorrow)
        task.run
        expect(task.diff_reports_per_dept).to_not have_key dept_code
        expect(task.errors_per_dept).to be_empty
      end
    end
  end

end
