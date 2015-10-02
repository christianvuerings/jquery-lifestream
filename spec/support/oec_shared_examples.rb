shared_context 'OEC enrollment data merge' do

  let(:fake_remote_drive) { double() }
  let(:merged_course_confirmations_csv) { File.read Rails.root.join('fixtures', 'oec', 'merged_course_confirmations.csv') }
  let(:merged_supervisor_confirmations_csv) { File.read Rails.root.join('fixtures', 'oec', 'supervisors.csv') }
  let(:merged_course_confirmations) { Oec::SisImportSheet.from_csv merged_course_confirmations_csv }

  let(:course_ids) { merged_course_confirmations_csv.scan(/2015-B-\d+/).uniq.flatten }

  let(:enrollment_data_rows) do
    rows = []
    course_ids.each do |course_id|
      next unless merged_course_confirmations.find { |row| row['COURSE_ID'] == course_id && row['EVALUATE'] == 'Y' }
      5.times { rows << {'course_id' => course_id, 'ldap_uid' => random_id} }
    end
    rows
  end

  let(:suffixed_enrollment_data_rows) { [] }

  let(:student_data_rows) do
    rows = []
    enrollment_data_rows.map { |row| row['ldap_uid'] }.uniq.each do |uid|
      rows << {
        'ldap_uid' => uid,
        'first_name' => 'Val',
        'last_name' => 'Valid',
        'email_address' => 'valid@berkeley.edu',
        'sis_id' => random_id
      }
    end
    rows
  end

  before(:each) do
    allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
    allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:export_csv)
                                  .and_return(merged_course_confirmations_csv, merged_supervisor_confirmations_csv)
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09 12:00:00')

    allow(Oec::Queries).to receive(:students_for_cntl_nums).and_return student_data_rows
    allow(Oec::Queries).to receive(:enrollments_for_cntl_nums).and_return(enrollment_data_rows, suffixed_enrollment_data_rows)
    allow_any_instance_of(Oec::Task).to receive(:default_term_dates).and_return({'START_DATE' => '01-26-2015', 'END_DATE' => '05-11-2015'})
  end

end
