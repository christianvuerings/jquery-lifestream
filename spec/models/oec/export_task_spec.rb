describe Oec::ExportTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::ExportTask.new(term_code: term_code, local_write: 'Y') }

  let(:fake_remote_drive) { double() }
  let(:merged_course_confirmations_csv) { File.read Rails.root.join('fixtures', 'oec', 'merged_course_confirmations.csv') }

  def read_exported_csv(filename)
    File.read Rails.root.join('tmp', 'oec', "#{filename}.csv")
  end

  let(:course_ids) { merged_course_confirmations_csv.scan(/2015-B-\d+/).uniq.flatten }

  let(:enrollment_data_rows) do
    rows = []
    course_ids.each { |course_id| 5.times { rows << {'course_id' => course_id, 'ldap_uid' => random_id} } }
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
    allow(fake_remote_drive).to receive(:export_csv).and_return merged_course_confirmations_csv
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09')

    allow(Oec::Queries).to receive(:students_for_cntl_nums).and_return student_data_rows
    allow(Oec::Queries).to receive(:enrollments_for_cntl_nums).and_return(enrollment_data_rows, suffixed_enrollment_data_rows)
  end

  let(:instructors) { Oec::Instructors.from_csv(read_exported_csv 'instructors') }
  let(:courses) { Oec::Courses.from_csv(read_exported_csv 'courses') }
  let(:students) { Oec::Students.from_csv(read_exported_csv 'students') }
  let(:course_instructors) { Oec::CourseInstructors.from_csv(read_exported_csv 'course_instructors') }
  let(:course_students) { Oec::CourseStudents.from_csv(read_exported_csv 'course_students') }

  context 'valid fixture data' do
    before { task.run }

    it 'should produce a sane instructors sheet' do
      expect(instructors).to have(16).items
      ('a'..'p').map do |l|
        matches = instructors.select { |instructor| instructor['LAST_NAME'] == (l*4).capitalize }
        expect(matches).to have(1).item
        expect(matches[0]['FIRST_NAME']).to start_with l.capitalize
        expect(matches[0]['EMAIL_ADDRESS']).to eq "#{l*4}@berkeley.edu"
      end
    end

    it 'should produce a sane courses sheet' do
      course_ids.each do |course_id|
        matches = courses.select { |course| course['COURSE_ID'] == course_id }
        expect(matches).to have(1).item
        expect(matches[0]['COURSE_ID']).to eq matches[0]['COURSE_ID_2']
      end
    end

    it 'should produce a sane course_instructors sheet' do
      expect(course_instructors.first).to_not be_empty
      course_instructors.each do |course_instructor|
        expect(courses.find { |course| course['COURSE_ID'] == course_instructor['COURSE_ID'] }).to be_present
        expect(instructors.find { |instructor| instructor['LDAP_UID'] == course_instructor['LDAP_UID'] }).to be_present
      end
    end

    it 'should produce a sane students sheet' do
      expect(students.first).to_not be_empty
      students.each do |student|
        expect(course_students.find { |course_student| course_student['LDAP_UID'] == student['LDAP_UID'] }).to be_present
      end
    end

    it 'should produce a sane course_students sheet' do
      expect(course_students.first).to_not be_empty
      course_students.each do |course_student|
        expect(courses.find { |course| course['COURSE_ID'] == course_student['COURSE_ID'] }).to be_present
        expect(students.find { |student| student['LDAP_UID'] == course_student['LDAP_UID'] }).to be_present
      end
    end
  end

  context 'data with suffixed course IDs' do
    before do
      merged_course_confirmations_csv.concat(
        '2015-B-34821_GSI,2015-B-34821_GSI,LGBT C146A LEC 001 REP SEXUALITY/LIT,Y,GWS/LGBT C146A LEC 001,LGBT,C146A,LEC,001,P,562283,10945601,Clarice,Cccc,cccc@berkeley.edu,1,23,,,G,,01-26-2015,05-11-2015')
      expect(Oec::Queries).to receive(:enrollments_for_cntl_nums)
        .with(term_code, ['34821'])
        .and_return student_ids.map { |id| {'course_id' => '2015-B-34821', 'ldap_uid' => id} }
      task.run
    end

    let(:student_ids) { %w(1000 2000 3000) }

    it 'should match appropriate data to suffixed CCN' do
      expect(courses.find { |course| course['COURSE_ID'] == '2015-B-34821_GSI'}).to be_present
      student_ids.each do |id|
        expect(course_students.find { |course_student| course_student['COURSE_ID'] == '2015-B-34821_GSI' && course_student['LDAP_UID'] == id }).to be_present
      end
      expect(course_instructors.find { |course_instructor| course_instructor['COURSE_ID'] == '2015-B-34821_GSI' && course_instructor['LDAP_UID'] == '562283'}).to be_present
    end
  end

  context 'conflicting data' do
    before do
      merged_course_confirmations_csv.concat(
        '2015-B-32960,2015-B-32960,GWS 103 LEC 001 IDENTITY ACROSS DIF,,,GWS,103,LEC,001,P,104033,UID:104033,BAD_FIRST_NAME,Ffff,ffff@berkeley.edu,1,23,,GENDER AND WOMEN\'S STUDIES,F,,01-26-2015,05-11-2015')
    end

    it 'should log error and abort' do
      expect(Rails.logger).to receive(:error).at_least(1).times do |error_message|
        expect(error_message.lines.first).to include "Sheet 'instructors' has conflicting values for key '104033'"
      end
      task.run
    end
  end

end
