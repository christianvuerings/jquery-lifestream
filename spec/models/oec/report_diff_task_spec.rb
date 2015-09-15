describe Oec::ReportDiffTask do

  context 'Report diff on fake data' do
    let(:term_code) { '2015-D' }
    let(:dept_code_mappings) {
      {
        'SZANT' => 'ANTHRO',
        'FOO' => nil,
        'PSTAT' => 'STAT',
        'SPOLS' => 'POL_SCI'
      }
    }
    let(:now) { DateTime.now }
    let(:datetime) { now.strftime('%F') }
    let(:remote_drive) { Oec::RemoteDrive.new }
    let (:fake_remote_drive) { double }
    subject { Oec::ReportDiffTask.new(term_code: term_code, dept_codes: dept_code_mappings.keys, local_write: true) }

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
      dept_code_mappings.each do |dept_code, dept_name|
        friendly_name = Berkeley::Departments.get(dept_code, concise: true)
        imports_path = [term_code, 'imports', datetime, friendly_name]
        if dept_name.nil?
          expect(fake_remote_drive).to receive(:find_nested).with(imports_path, anything).and_return nil
        else
          courses_path = [term_code, 'departments', friendly_name, 'Courses']
          [ imports_path, courses_path ].each_with_index do |path, index|
            expect(fake_remote_drive).to receive(:find_nested).with(path, anything).and_return (remote_file = double)
            expect(fake_remote_drive).to receive(:export_csv).with(remote_file).and_return (import_csv = double)
            spreadsheet = fake_csv_hash[dept_name][index]
            allow(Oec::SisImportSheet).to receive(:from_csv).with(import_csv, dept_code: dept_code).and_return spreadsheet
          end
        end
      end
      subject.run
    }

    it 'should log errors' do
      expect(subject.errors_per_dept).to have(2).items
      expect(subject.errors_per_dept['FOO']).to have(1).item
      expect(subject.errors_per_dept['PSTAT']).to have(2).item
      expect(subject.errors_per_dept['PSTAT']['99999']).to have(1).item
      expect(subject.errors_per_dept['PSTAT']['99999'][0]).to include 'Invalid CCN annotation'
      expect(subject.errors_per_dept['PSTAT']['87673']).to have(2).items
      expect(subject.errors_per_dept['PSTAT']['87673'][0]).to include 'Invalid ldap_uid'
      expect(subject.errors_per_dept['PSTAT']['87673'][1]).to include 'Invalid instructor_func'
    end
  end

end
