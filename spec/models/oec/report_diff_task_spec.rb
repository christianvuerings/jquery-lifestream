describe Oec::ReportDiffTask do

  let(:now) { DateTime.now }

  context 'Report diff on fake data' do
    let(:term_code) { '2015-D' }
    # Map dept_code to test-data filenames under fixtures/oec
    let(:dept_code_mappings) {
      {
        'SZANT' => 'ANTHRO',
        'FOO' => nil,
        'PSTAT' => 'STAT',
        'SPOLS' => 'POL_SCI'
      }
    }
    let (:fake_remote_drive) { double }
    subject { Oec::ReportDiffTask.new(term_code: term_code, dept_codes: dept_code_mappings.keys, date_time: now, local_write: true) }

    before {
      allow(Oec::CourseCode).to receive(:by_dept_code).and_return dept_code_mappings
      allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
      allow(fake_remote_drive).to receive(:check_conflicts_and_upload)
      fake_csv_hash = {}
      modified_stat_data = File.read File.open("#{Rails.root}/fixtures/oec/modified_by_dept_STAT.json")
      Dir.glob(Rails.root.join 'fixtures', 'oec', 'courses_for_dept_*.json').each do |json|
        dept_name = json.partition('for_dept_').last.sub(/.json$/, '')
        sis_data = JSON.parse(File.read json)
        # Two entries for each dept: sis_data and modified data. In this test, only STAT data has been modified.
        dept_data = dept_name == 'STAT' ? JSON.parse(modified_stat_data) : sis_data
        fake_csv_hash[dept_name] = [ sis_data, dept_data]
      end
      # Behave as if there is no previous diff report on remote drive
      expect(fake_remote_drive).to receive(:find_nested).with([term_code, 'departments']).and_return (departments_folder = double)
      expect(fake_remote_drive).to receive(:find_first_matching_item).with('2015-D diff report', departments_folder).and_return nil
      dept_code_mappings.each do |dept_code, dept_name|
        friendly_name = Berkeley::Departments.get(dept_code, concise: true)
        imports_path = [term_code, 'imports', now.strftime('%F %H:%M:%S'), friendly_name]
        if dept_name.nil?
          expect(fake_remote_drive).to receive(:find_nested).with(imports_path, anything).and_return nil
        else
          courses_path = [term_code, 'departments', friendly_name]
          sheet_classes = [Oec::SisImportSheet, Oec::CourseConfirmation]
          [ imports_path, courses_path ].each_with_index do |path, index|
            expect(fake_remote_drive).to receive(:find_nested).with(path, anything).and_return (remote_file = double)
            expect(fake_remote_drive).to receive(:export_csv).with(remote_file).and_return (import_csv = double)
            spreadsheet = fake_csv_hash[dept_name][index]
            allow(sheet_classes[index]).to receive(:from_csv).with(import_csv, dept_code: dept_code).and_return spreadsheet
          end
        end
      end
      subject.run
    }

    it 'should log errors' do
      expect(subject.errors).to have(2).items
      expect(subject.errors['FOO']).to have(1).item
      expect(subject.errors['PSTAT']).to have(2).item
      expect(subject.errors['PSTAT']['87672'].keys).to match_array ['Invalid EVALUATION_TYPE: X']
      expect(subject.errors['PSTAT']['99999'].keys).to match_array ['Invalid annotation: wrong', 'Invalid ldap_uid: bad_data']
    end

    it 'should report STAT diff' do
      pstat_diff_rows = subject.diff_report.select { |row| row['DEPT_CODE'] == 'PSTAT' }
      expect(pstat_diff_rows).to have(8).items
      expected_diff = {
        '2015-B-87672-10316' => {
          '+/-' => ' ',
          'COURSE_NAME' => 'different_course_name',
          'sis:COURSE_NAME' => 'STAT C205A LEC 001 - PROB THEORY',
          'EMAIL_ADDRESS' => 'different_email_address@berkeley.edu',
          'sis:EMAIL_ADDRESS' => 'blanco@berkeley.edu'
        },
        '2015-B-87690-12345678' => {
          '+/-' => '-',
          'COURSE_NAME' => nil,
          'sis:COURSE_NAME' => 'STAT C236A LEC 001 - STATS SOCI SCI',
          'EMAIL_ADDRESS' => nil,
          'sis:EMAIL_ADDRESS' => 'stat_supervisor@berkeley.edu'
        },
        '2015-B-11111' => {
          '+/-' => '+',
          'COURSE_NAME' => 'Added by dept',
          'sis:COURSE_NAME' => nil,
          'EMAIL_ADDRESS' => 'trump@berkeley.edu',
          'sis:EMAIL_ADDRESS' => nil
        }
      }
      pstat_diff_rows.each do |row|
        row_key = row['KEY']
        if expected_diff.has_key? row_key
          expected_diff[row_key].each do |key, expected|
            actual = row[key]
            expect(expected).to eq(actual), "#{row_key}: expected '#{expected}', got '#{actual}' where key=#{key}"
          end
          expected_diff.delete row_key
        end
      end
      expect(expected_diff).to be_empty
    end

  end
end
