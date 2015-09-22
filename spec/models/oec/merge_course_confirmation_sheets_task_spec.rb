describe Oec::MergeConfirmationSheetsTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::MergeConfirmationSheetsTask.new(term_code: term_code, local_write: local_write) }

  let(:fake_remote_drive) { double() }

  let(:last_import_folder) { mock_google_drive_item }
  let(:gws_folder) { mock_google_drive_item('Gender and Women\'s Studies') }
  let(:mcellbi_folder) { mock_google_drive_item('Molecular and Cell Biology') }

  def mock_sheet(filename)
    sheet = {
      sheet: mock_google_drive_item(filename),
      csv: File.read(Rails.root.join('fixtures', 'oec', "#{filename}.csv"))
    }
    @mock_sheets << sheet
    sheet
  end

  let(:supervisors) { mock_sheet 'supervisors' }
  let(:gws_import) { mock_sheet 'import_GWS' }
  let(:gws_course_confirmation) { mock_sheet 'course_confirmations_GWS' }
  let(:gws_supervisor_confirmation) { mock_sheet 'supervisor_confirmations_GWS' }
  let(:mcellbi_import) { mock_sheet 'import_MCELLBI' }
  let(:mcellbi_course_confirmation) { mock_sheet 'course_confirmations_MCELLBI' }
  let(:mcellbi_supervisor_confirmation) { mock_sheet 'supervisor_confirmations_MCELLBI' }

  before(:each) do
    @mock_sheets = []

    allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09')

    allow(fake_remote_drive).to receive(:check_conflicts_and_create_folder).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:find_first_matching_item).and_return mock_google_drive_item

    allow(fake_remote_drive).to receive(:find_folders).and_return([last_import_folder], [gws_folder, mcellbi_folder])

    allow(fake_remote_drive).to receive(:find_first_matching_item).with('supervisors', anything).and_return supervisors[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Courses', gws_folder).and_return gws_course_confirmation[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Report Viewers', gws_folder).and_return gws_supervisor_confirmation[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Courses', mcellbi_folder).and_return mcellbi_course_confirmation[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Report Viewers', mcellbi_folder).and_return mcellbi_supervisor_confirmation[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Gender and Women\'s Studies', last_import_folder).and_return gws_import[:sheet]
    allow(fake_remote_drive).to receive(:find_first_matching_item).with('Molecular and Cell Biology', last_import_folder).and_return mcellbi_import[:sheet]

    @mock_sheets.each { |sheet| allow(fake_remote_drive).to receive(:export_csv).with(sheet[:sheet]).and_return sheet[:csv] }
  end

  after(:all) do
    FileUtils.rm_rf Rails.root.join('tmp', 'oec', 'Merged course confirmations.csv')
    FileUtils.rm_rf Rails.root.join('tmp', 'oec', 'Merged supervisor confirmations.csv')
    Dir.glob(Rails.root.join 'tmp', 'oec', "*#{Oec::CreateConfirmationSheetsTask.name.demodulize.underscore}.log").each do |file|
      FileUtils.rm_rf file
    end
  end

  context 'expected API calls' do
    let(:local_write) { nil }

    it 'should upload merged confirmation sheets and log' do
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload).with(kind_of(Oec::SisImportSheet), 'Merged course confirmations', Oec::Worksheet, anything, anything).and_return true
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload).with(kind_of(Oec::Supervisors), 'Merged supervisor confirmations', Oec::Worksheet, anything, anything).and_return true
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload).with(kind_of(Pathname), kind_of(String), 'text/plain', anything, anything).and_return true
      task.run
    end
  end

  context 'generated sheet structure' do
    let(:local_write) { 'Y' }
    let(:merged_course_confirmation) { Oec::SisImportSheet.from_csv(File.read Rails.root.join('tmp', 'oec', 'Merged course confirmations.csv')) }
    let(:merged_supervisor_confirmation) { Oec::Supervisors.from_csv(File.read Rails.root.join('tmp', 'oec', 'Merged supervisor confirmations.csv')) }

    let(:gws_course_confirmation_worksheet) { Oec::CourseConfirmation.from_csv gws_course_confirmation[:csv] }
    let(:mcellbi_course_confirmation_worksheet) { Oec::CourseConfirmation.from_csv mcellbi_course_confirmation[:csv] }
    let(:gws_supervisor_confirmation_worksheet) { Oec::SupervisorConfirmation.from_csv gws_supervisor_confirmation[:csv] }
    let(:mcellbi_supervisor_confirmation_worksheet) { Oec::SupervisorConfirmation.from_csv mcellbi_supervisor_confirmation[:csv] }
    let(:gws_sis_import) { Oec::SisImportSheet.from_csv gws_import[:csv] }
    let(:mcellbi_sis_import) { Oec::SisImportSheet.from_csv mcellbi_import[:csv] }
    let(:supervisors_worksheet) { Oec::Supervisors.from_csv supervisors[:csv] }

    before { task.run }

    it 'should produce a merged course confirmation' do
      expect(merged_course_confirmation.first).to_not be_empty
    end

    it 'should include only courses marked for evaluation' do
      [gws_course_confirmation_worksheet, mcellbi_course_confirmation_worksheet].each do |confirmation|
        confirmation.each do |confirmation_row|
          merged_row = merged_course_confirmation.find { |row| row['COURSE_ID'] == confirmation_row['COURSE_ID'] && row['LDAP_UID'] == confirmation_row['LDAP_UID'] }
          if confirmation_row['EVALUATE'].blank?
            expect(merged_row).to be_nil
          else
            expect(merged_row).to be_present
          end
        end
      end
    end

    it 'should overwrite SIS import data when confirmed course data includes column' do
      [gws_course_confirmation_worksheet, gws_sis_import, mcellbi_course_confirmation_worksheet, mcellbi_sis_import].each_slice(2) do |confirmation, sis_import|
        confirmation.each do |confirmation_row|
          merged_confirmation_row = merged_course_confirmation.find { |row| row['COURSE_ID'] == confirmation_row['COURSE_ID'] && row['LDAP_UID'] == confirmation_row['LDAP_UID'] }
          if confirmation_row['EVALUATE'].blank?
            expect(merged_confirmation_row).to be_nil
          else
            sis_import_row = sis_import.find { |row| row['COURSE_ID'] == confirmation_row['COURSE_ID'] && row['LDAP_UID'] == confirmation_row['LDAP_UID'] }
            merged_course_confirmation.headers.each do |header|
              if confirmation.headers.include? header
                expect(merged_confirmation_row[header]).to eq confirmation_row[header]
              else
                expect(merged_confirmation_row[header]).to eq sis_import_row[header]
              end
            end
          end
        end
      end
    end

    it 'should produce a merged supervisors confirmation' do
      expect(merged_supervisor_confirmation.first).to_not be_empty
    end

    it 'should overwrite supervisors sheet when confirmed report viewers sheet includes column' do
      [gws_supervisor_confirmation_worksheet, mcellbi_supervisor_confirmation_worksheet].each do |confirmation|
        confirmation.each do |confirmation_row|
          merged_confirmation_row = merged_supervisor_confirmation.find { |row| row['LDAP_UID'] == confirmation_row['LDAP_UID'] }
          supervisors_row = supervisors_worksheet.find { |row| row['LDAP_UID'] == confirmation_row['LDAP_UID'] }
          merged_course_confirmation.headers.each do |header|
            if confirmation.headers.include? header
              expect(merged_confirmation_row[header]).to eq confirmation_row[header]
            else
              expect(merged_confirmation_row[header]).to eq supervisors_row[header]
            end
          end
        end
      end
    end
  end

  context 'when two departments mark a course for evaluation with conflicting data' do
    let(:local_write) { 'Y' }
    before do
      gws_import[:csv].concat '2015-B-91111,2015-B-91111,GWS 165 LEC 001 MEIOSIS AND GENDER TROUBLE,Y,GWS/MCELLBI 165 LEC 001,GWS,165,LEC,001,P,100008,Instructor,Eight,instructor8@berkeley.edu,1,,,F,,1/20/2015,5/8/2015'
      mcellbi_import[:csv].concat '2015-B-91111,2015-B-91111,GWS 165 LEC 001 MEIOSIS AND GENDER TROUBLE,Y,GWS/MCELLBI 165 LEC 001,GWS,165,LEC,001,P,100008,Instructor,Eight,instructor8@berkeley.edu,1,,,F,,1/20/2015,5/8/2015'
      gws_course_confirmation[:csv].concat '2015-B-91111,GWS 165 LEC 001 MEIOSIS AND GENDER TROUBLE,Y,GWS/MCELLBI 165 LEC 001,100008,Instructor,Eight,instructor8@berkeley.edu,1,Y,GWS,F,,1/20/2015,5/8/2015'
      mcellbi_course_confirmation[:csv].concat '2015-B-91111,GWS 165 LEC 001 MEIOSIS AND GENDER TROUBLE,Y,GWS/MCELLBI 165 LEC 001,100008,Instructor,Eight,instructor8@berkeley.edu,1,Y,MCELLBI,F,,1/20/2015,5/8/2015'
    end

    it 'should not export and should record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      expect(task.errors['Merged course confirmations']['2015-B-91111-100008'].keys).to eq ["Conflicting values found under DEPT_FORM: 'GWS', 'MCELLBI'"]
    end
  end

  context 'when confirmed course data cannot be matched to SIS import' do
    let(:local_write) { 'Y' }
    before do
      gws_course_confirmation[:csv].concat '2015-B-91111,GWS 165 LEC 001 MEIOSIS AND GENDER TROUBLE,Y,GWS/MCELLBI 165 LEC 001,100008,Instructor,Eight,instructor8@berkeley.edu,1,Y,GWS,F,,1/20/2015,5/8/2015'
    end

    it 'should not export and should record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      expect(task.errors['Merged course confirmations']['2015-B-91111-100008'].keys).to eq ['No SIS import row found matching confirmation row']
    end
  end

  context 'when supervisor data conflicts between department forms' do
    let(:local_write) { 'Y' }
    before do
      supervisors[:csv].concat '999999,UID:999999,Alice,Sheldon,raccoona@berkeley.edu,DEPT_ADMIN,Y,,MCELLBI,GWS,,,'
      gws_supervisor_confirmation[:csv].concat '999999,Raccoona,Sheldon,raccoona@berkeley.edu,DEPT_ADMIN,Y,,MCELLBI,GWS,,,'
      mcellbi_supervisor_confirmation[:csv].concat '999999,James,Tiptree,raccoona@berkeley.edu,DEPT_ADMIN,Y,,MCELLBI,GWS,,,'
    end

    it 'should not export and should record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      pp task.errors
      expect(task.errors['Merged supervisor confirmations']['999999'].keys).to match_array([
        "Conflicting values found under FIRST_NAME: 'Raccoona', 'James'",
        "Conflicting values found under LAST_NAME: 'Sheldon', 'Tiptree'",
      ])
    end
  end

  context 'when confirmed supervisor data cannot be matched to supervisors sheet' do
    let(:local_write) { 'Y' }
    before do
      mcellbi_supervisor_confirmation[:csv].concat '999999,Alice,Sheldon,raccoona@berkeley.edu,DEPT_ADMIN,,,MCELLBI,GWS,,,'
    end

    it 'should not export and should record errors' do
      expect(task).not_to receive :export_sheet
      expect(Rails.logger).to receive(:error).at_least(1).times
      task.run
      expect(task.errors['Merged supervisor confirmations']['999999'].keys).to eq ['No supervisors row found matching confirmation row']
    end
  end
end
