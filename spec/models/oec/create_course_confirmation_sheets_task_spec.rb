describe Oec::CreateConfirmationSheetsTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::CreateConfirmationSheetsTask.new(term_code: term_code, local_write: local_write) }

  let(:fake_remote_drive) { double() }

  let(:import_sheet) { mock_google_drive_item('Molecular and Cell Biology') }
  let(:departments_folder) { mock_google_drive_item }
  let(:supervisors_sheet) { mock_google_drive_item }

  let(:import_csv) { File.read Rails.root.join('fixtures', 'oec', 'import_MCELLBI.csv') }
  let(:supervisors_csv) { File.read Rails.root.join('fixtures', 'oec', 'supervisors.csv') }

  before(:each) do
    allow(Oec::CourseCode).to receive(:by_dept_code).and_return({'IMMCB' => [double(dept_name: 'MCELLBI')]})
    allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09')

    allow(fake_remote_drive).to receive(:check_conflicts_and_create_folder).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_folders).and_return [mock_google_drive_item]
    allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item

    allow(fake_remote_drive).to receive(:get_items_in_folder).and_return [import_sheet]

    allow(fake_remote_drive).to receive(:find_first_matching_item).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('departments', anything).and_return departments_folder
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Molecular and Cell Biology', departments_folder).and_return nil
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('supervisors', anything).and_return supervisors_sheet

    allow(fake_remote_drive).to receive(:export_csv).with(import_sheet).and_return import_csv
    allow(fake_remote_drive).to receive(:export_csv).with(supervisors_sheet).and_return supervisors_csv
  end

  after(:all) do
    FileUtils.rm_rf Rails.root.join('tmp', 'oec', 'Courses.csv')
    FileUtils.rm_rf Rails.root.join('tmp', 'oec', 'Report Viewers.csv')
    Dir.glob(Rails.root.join 'tmp', 'oec', "*#{Oec::CreateConfirmationSheetsTask.name.demodulize.underscore}.log").each do |file|
      FileUtils.rm_rf file
    end
  end

  context 'expected API calls' do
    let(:local_write) { nil }
    let(:template) { double(id: 'template_id', title: 'TEMPLATE', mime_type: 'application/vnd.google-apps.spreadsheet') }
    let(:spreadsheet) { double(worksheets: [courses_worksheet, report_viewers_worksheet]) }
    let(:courses_worksheet) { double(title: 'Courses', rows: [Oec::CourseConfirmation.new.headers]) }
    let(:report_viewers_worksheet) { double(title: 'Report Viewers', rows: [Oec::Supervisors.new.headers]) }

    it 'should copy template, update cells and upload log' do
      expect(fake_remote_drive).to receive(:find_first_matching_item).with('TEMPLATE', anything).and_return template
      expect(fake_remote_drive).to receive(:copy_item).with(template.id, 'Molecular and Cell Biology').and_return double(id: 'spreadsheet_id')
      expect(fake_remote_drive).to receive(:spreadsheet_by_id).with('spreadsheet_id').and_return spreadsheet

      expect(fake_remote_drive).to receive(:update_worksheet).with(courses_worksheet, anything)
      expect(fake_remote_drive).to receive(:update_worksheet).with(report_viewers_worksheet, anything)
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload).with(kind_of(Pathname), kind_of(String), 'text/plain', anything, anything).and_return true

      task.run
    end
  end

  context 'generated sheet structure' do
    let(:local_write) { 'Y' }

    it 'should produce sane course confirmation sheets' do
      task.run
      confirmation_sheet = Oec::CourseConfirmation.from_csv(File.read Rails.root.join('tmp', 'oec', 'Courses.csv'))
      expect(confirmation_sheet.first).to_not be_empty
      import_sheet = Oec::SisImportSheet.from_csv import_csv
      import_sheet.each do |import_row|
        confirmation_row = confirmation_sheet.find { |row| row['COURSE_ID'] == import_row['COURSE_ID'] && row['LDAP_UID'] == import_row['LDAP_UID'] }
        confirmation_sheet.headers.each do |header|
          expect(confirmation_row[header]).to eq import_row[header]
        end
      end
    end

    it 'should produce sane report viewers sheets' do
      task.run
      confirmation_sheet = Oec::SupervisorConfirmation.from_csv(File.read Rails.root.join('tmp', 'oec', 'Report Viewers.csv'))
      expect(confirmation_sheet.first).to_not be_empty
      supervisors_sheet = Oec::Supervisors.from_csv supervisors_csv
      supervisors_sheet.each do |supervisor_row|
        confirmation_row = confirmation_sheet.find { |row| row['LDAP_UID'] == supervisor_row['LDAP_UID'] }
        if supervisor_row['DEPT_NAME_1'] == 'MCELLBI' || supervisor_row['DEPT_NAME_2'] == 'MCELLBI'
          confirmation_sheet.headers.each do |header|
            expect(confirmation_row[header]).to eq supervisor_row[header]
          end
        else
          expect(confirmation_row).to be_nil
        end
      end
    end

  end

  context 'conflicting course data' do
    let(:local_write) { 'Y' }
    let(:conflicting_row) { '2015-B-58070,2015-B-58070,MCELLBI 102 LEC 001 SURV BIOCHEM & MOBI,,,MCELLBI,102,LEC,1,P,100001,UID:100001,Monster,Zero,monster.zero@berkeley.edu,1,23,,MCELLBI,F,Y,2/1/2015,4/1/2015' }
    before { import_csv.concat conflicting_row }

    it 'should not export and record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      expect(task.errors.keys).to eq ['Courses']
      expect(task.errors['Courses'].keys).to eq ['2015-B-58070-100001']
      expect(task.errors['Courses']['2015-B-58070-100001'].keys).to include("Conflicting values found under FIRST_NAME: 'Instructor', 'Monster'")
      expect(task.errors['Courses']['2015-B-58070-100001'].keys).to include("Conflicting values found under LAST_NAME: 'One', 'Zero'")
      expect(task.errors['Courses']['2015-B-58070-100001'].keys).to include("Conflicting values found under EMAIL_ADDRESS: 'instructor1@berkeley.edu', 'monster.zero@berkeley.edu'")
    end
  end

  context 'conflicting supervisor data' do
    let(:local_write) { 'Y' }
    let(:conflicting_row) { '245968,UID:245968,Bronwen,Biology,biology2@berkeley.edu,DEPT_ADMIN,,,PLANTBI,MCELLBI,,,' }
    before { supervisors_csv.concat conflicting_row }

    it 'should not export and record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      expect(task.errors.keys).to eq ['Report Viewers']
      expect(task.errors['Report Viewers'].keys).to eq ['245968']
      expect(task.errors['Report Viewers']['245968'].keys).to eq ["Conflicting values found under DEPT_NAME_1: 'INTEGBI', 'PLANTBI'"]
    end
  end
end
