describe Oec::RemoteDrive do

  subject { described_class.new }
  let(:term_code) { '2015-D' }
  let(:dept_code) { 'IQBBB' }
  # DateTime.tomorrow to avoid collision with other testing on today's data
  let(:tomorrow) { DateTime.tomorrow.strftime('%F') }

  context '#real', testext: true, :order => :defined do

    context 'find no match' do
      it 'should return nil when term not found' do
        spreadsheet = subject.find_dept_courses_spreadsheet('2008-B', dept_code)
        expect(spreadsheet).to be_nil
      end

      it 'should return nil when dept \'Courses\' spreadsheet is not found' do
        spreadsheet = subject.find_dept_courses_spreadsheet(term_code, dept_code)
        expect(spreadsheet).to be_nil
      end

      it 'should return nil when dept not found' do
        spreadsheet = subject.find_nested [term_code, 'imports', tomorrow, dept_code]
        expect(spreadsheet).to be_nil
      end
    end

    context 'imports folder', :order => :defined do
      before {
        worksheet = Oec::SisImportSheet.new(dept_code: dept_code)
        course_codes = [Oec::CourseCode.new(dept_name: 'SPANISH', catalog_id: '', dept_code: dept_code, include_in_oec: true)]
        Oec::SisImportTask.new(:term_code => term_code).import_courses(worksheet, course_codes)
        @imports = subject.find_nested([term_code, 'imports'], on_failure: :error)
        tomorrow_folder = subject.find_first_matching_folder(tomorrow, @imports) ||
          subject.create_folder(tomorrow, @imports.id)
        @dept_import = subject.check_conflicts_and_upload(worksheet, dept_code, Oec::Worksheet, tomorrow_folder)
      }

      after {
        now_import_folder = subject.find_first_matching_folder(tomorrow, @imports)
        subject.trash_item(now_import_folder, permanently_delete: true) if now_import_folder
      }

      it 'should find newly created department import' do
        spreadsheet = subject.find_nested [term_code, 'imports', tomorrow, dept_code]
        expect(spreadsheet).to_not be_nil
      end
    end
  end

end
