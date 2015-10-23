describe Oec::RemoteDrive do

  subject { described_class.new }
  let(:william_the_conqueror_term_code) { '2525-D' }
  let(:dept_code) { 'IQBBB' }
  let(:now) { DateTime.now }

  context '#real', testext: true, :order => :defined do

    context 'find no match' do
      it 'should return nil when term not found' do
        spreadsheet = subject.find_nested ['1000-A', Oec::Folder.confirmations, dept_code]
        expect(spreadsheet).to be_nil
      end

      it 'should return nil when department confirmation spreadsheet is not found' do
        spreadsheet = subject.find_nested [william_the_conqueror_term_code, Oec::Folder.confirmations, dept_code]
        expect(spreadsheet).to be_nil
      end

      it 'should return nil when dept not found' do
        spreadsheet = subject.find_nested [william_the_conqueror_term_code, Oec::Folder.sis_imports, now.strftime('%F'), dept_code]
        expect(spreadsheet).to be_nil
      end
    end

    context 'imports folder', :order => :defined do
      let(:transient_folder_name) { "#{described_class} tested on #{now.strftime '%m/%d/%Y at %I:%M%p'}" }

      before {
        worksheet = Oec::SisImportSheet.new(dept_code: dept_code)
        course_codes = [Oec::CourseCode.new(dept_name: 'SPANISH', catalog_id: '', dept_code: dept_code, include_in_oec: true)]
        # Import of '2015-D' is intentional because we want valid data as input.
        Oec::SisImportTask.new(:term_code => '2015-D').import_courses(worksheet, course_codes)
        @folder = subject.create_folder transient_folder_name
        subject.check_conflicts_and_upload(worksheet, dept_code, Oec::Worksheet, @folder)
      }

      after {
        subject.trash_item(@folder, permanently_delete: true)
      }

      it 'should find newly created department import' do
        spreadsheet = subject.find_nested [transient_folder_name, dept_code]
        expect(spreadsheet).to_not be_nil
      end
    end
  end

end
