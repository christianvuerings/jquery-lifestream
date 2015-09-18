describe Oec::CreateConfirmationSheetsTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::CreateConfirmationSheetsTask.new(term_code: term_code, local_write: local_write) }

  let(:fake_remote_drive) { double() }
  let(:import_csv) { File.read Rails.root.join('fixtures', 'oec', 'import_MCELLBI.csv') }

  before(:each) do
    allow(Oec::CourseCode).to receive(:by_dept_code).and_return({'IMMCB' => []})
    allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
    allow(fake_remote_drive).to receive(:check_conflicts_and_create_folder).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_first_matching_item).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_folders).and_return [mock_google_drive_item]
    allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:export_csv).and_return(import_csv)
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09')
  end

  after(:all) do
    FileUtils.rm_rf Rails.root.join('tmp', 'oec', 'Courses.csv')
    Dir.glob(Rails.root.join 'tmp', 'oec', "*#{Oec::CreateConfirmationSheetsTask.name.demodulize.underscore}.log").each do |file|
      FileUtils.rm_rf file
    end
  end

  context 'expected API calls' do
    let(:local_write) { nil }

    it 'should upload confirmation sheet and log' do
      expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder).with('Molecular and Cell Biology', anything, anything).and_return true
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload).with(kind_of(Oec::CourseConfirmation), 'Courses', Oec::Worksheet, anything, anything).and_return true
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

  end

  context 'conflicting data' do
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

end
