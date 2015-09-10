describe Oec::SisImportTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::SisImportTask.new(term_code: term_code) }

  let(:fake_remote_drive) { double() }
  let(:supplemental_courses_csv) { Oec::Courses.new.headers.join(',') }

  before(:each) do
    allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
    allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item
    allow(fake_remote_drive).to receive(:export_csv).and_return supplemental_courses_csv
    allow(Settings.terms).to receive(:fake_now).and_return DateTime.parse('2015-03-09')
  end

  describe 'CSV export' do
    subject do
      task.import_courses(courses, fake_code_mapping)
      courses.write_csv
      CSV.read(courses.csv_export_path).slice(1..-1).map { |row| Hash[ courses.headers.zip(row) ]}
    end

    let(:courses) { Oec::SisImportSheet.new(dept_code: dept_name) }
    let(:courses_by_ccn) { {} }
    let(:courses_for_dept) { [] }
    let(:additional_cross_listings) { Set.new }
    let(:fake_code_mapping) { [Oec::CourseCode.new(dept_name: dept_name, catalog_id: nil, dept_code: dept_name, include_in_oec: true)] }
    let(:course_id_column) { subject.map { |row| row['COURSE_ID'] } }

    def load_fixture_courses
      Dir.glob(Rails.root.join 'fixtures', 'oec', 'courses_for_dept_*.json').each do |json|
        courses = JSON.parse(File.read json)
        courses_for_dept.concat courses if json.include? dept_name.gsub(' ', '_')
        courses.each do |course_info|
          courses_by_ccn[course_info['course_cntl_num']] ||= []
          courses_by_ccn[course_info['course_cntl_num']] << course_info
          if json.include? dept_name.gsub(' ', '_')
            additional_cross_listings.merge(course_info['cross_listed_ccns'].split(',')) if course_info['cross_listed_ccns']
            additional_cross_listings.merge(course_info['co_scheduled_ccns'].split(',')) if course_info['co_scheduled_ccns']
          end
        end
      end
      additional_cross_listings.delete_if { |ccn| courses_for_dept.find{|course| course['course_cntl_num'] == ccn } }
    end

    before(:each) do
      load_fixture_courses
      expect(Oec::Queries).to receive(:courses_for_codes)
        .with(term_code, fake_code_mapping, nil).exactly(1).times
        .and_return courses_for_dept
      expect(Oec::Queries).to receive(:courses_for_cntl_nums)
        .with(term_code, additional_cross_listings.to_a).exactly(1).times
        .and_return courses_by_ccn.slice(*additional_cross_listings.to_a).values.flatten
    end

    shared_examples 'expected CSV structure' do
      it { expect(course_id_column).to contain_exactly(*expected_ids) }
      it 'should include dept_form only for non-crosslisted courses' do
        subject.each do |row|
          courses.headers.each { |header| expect(row).to have_key header }
          if row['CROSS_LISTED_FLAG'] == 'Y'
            expect(row['DEPT_FORM']).to be_nil
          else
            expect(row['DEPT_FORM']).to be_present
          end
          expect(row['BLUE_ROLE']).to eq '23'
          expect(row['EVALUATE']).to be_nil
          %w(COURSE_ID COURSE_NAME DEPT_NAME CATALOG_ID INSTRUCTION_FORMAT SECTION_NUM EVALUATION_TYPE START_DATE END_DATE).each do |key|
            expect(row[key]).to be_present
          end
          expect(%w(P S)).to include row['PRIMARY_SECONDARY_CD']
          expect(row['COURSE_ID_2']).to eq row['COURSE_ID']
        end
      end
    end

    context 'ANTHRO dept' do
      let(:dept_name) { 'ANTHRO' }
      let(:expected_ids) { %w(2015-B-02567) }
      include_examples 'expected CSV structure'
      it 'should not include IND course' do
        expect(course_id_column).not_to include('2015-B-06789')
      end
    end

    context 'MATH dept' do
      let(:dept_name) { 'MATH' }
      let(:expected_ids) { %w(2015-B-54432 2015-B-54441 2015-B-87672 2015-B-87675) }
      before { allow(Oec::CourseCode).to receive(:included?).with('STAT', anything).and_return true  }
      include_examples 'expected CSV structure'
    end

    context 'POL SCI dept' do
      let(:dept_name) { 'POL SCI' }
      let(:expected_ids) { %w(2015-B-87690 2015-B-72198 2015-B-72198_GSI 2015-B-72199) }
      include_examples 'expected CSV structure'
      it 'should not include GRP course' do
        expect(course_id_column).not_to include('2015-B-71523')
      end

      it 'should flag courses with joint faculty and GSI instructors' do
        joint_course_rows = subject.select { |row| row['COURSE_ID'].start_with? '2015-B-72198' }
        expect(joint_course_rows).to have(2).items
        expect(joint_course_rows.find { |row| row['COURSE_ID'] == '2015-B-72198' }['EVALUATION_TYPE']).to eq 'F'
        expect(joint_course_rows.find { |row| row['COURSE_ID'] == '2015-B-72198_GSI' }['EVALUATION_TYPE']).to eq 'G'
      end

      context 'supplemental data overrides' do
        let(:supplemental_courses_csv) { File.read Rails.root.join('fixtures', 'oec', 'supplemental_sources_courses.csv') }
        let(:expected_ids) { %w(2015-B-87690 2015-B-72198 2015-B-72198_GSI 2015-B-72199) }

        include_examples 'expected CSV structure'

        it 'adds modular course data to matching rows only' do
          subject.each do |row|
            if row['COURSE_NAME'].start_with? 'POL SCI 115'
              expect(row['MODULAR_COURSE']).to eq 'Y'
              expect(row['START_DATE']).to eq '01-27-2015'
              expect(row['END_DATE']).to eq '05-16-2015'
            else
              expect(row['MODULAR_COURSE']).to be_blank
              expect(row['START_DATE']).to eq '01-20-2015'
              expect(row['END_DATE']).to eq '05-08-2015'
            end
          end
        end

        context 'non-matching rows in supplemental data' do
          let(:supplemental_courses_csv) do
            csv = File.read Rails.root.join('fixtures', 'oec', 'supplemental_sources_courses.csv')
            csv << "\n,,,,,POL SCI,215,,,,,,,Y,01-20-2015,05-16-2015"
            csv << "\n,,,,,FRENCH,215,,,,,,,Y,01-20-2015,05-16-2015"
          end

          it 'appends unmatched row with course code matching worksheet' do
            expect(subject.last['DEPT_NAME']).to eq 'POL SCI'
            expect(subject.last['CATALOG_ID']).to eq '215'
            expect(subject.last['MODULAR_COURSE']).to eq 'Y'
            expect(subject.last['COURSE_ID']).to be_blank
          end

          it 'does not append unmatched row with course code not matching worksheet' do
            expect(subject.find { |row| row['DEPT_NAME'] == 'FRENCH' }).to be_nil
          end
        end
      end
    end

    context 'STAT dept' do
      let(:dept_name) { 'STAT' }
      let(:expected_ids) { %w(2015-B-87672 2015-B-87673 2015-B-87675 2015-B-54432 2015-B-54441 2015-B-72199 2015-B-87690 2015-B-87693) }
      before { allow(Oec::CourseCode).to receive(:included?).with('MATH', anything).and_return math_included  }
      let(:math_included) { true }

      include_examples 'expected CSV structure'

      it 'should not include course supervisor assignments' do
        expect(subject.map{ |row| row['INSTRUCTOR_FUNC'] }).not_to include '3'
      end

      it 'reports official crosslistings' do
        crosslisting = subject.select{ |row| row['CROSS_LISTED_NAME'] == 'POL SCI/STAT C236A LEC 001' }
        expect(crosslisting.count).to eq 2
        expect(crosslisting).to all include({'CROSS_LISTED_FLAG' => 'Y'})
      end

      it 'reports non-student academic employees as faculty' do
        expect(subject.find{|row| row['COURSE_ID'] == '2015-B-87672'}['EVALUATION_TYPE']).to eq 'F'
      end
      it 'reports student academic employees as GSIs' do
        expect(subject.find{|row| row['COURSE_ID'] == '2015-B-87693'}['EVALUATION_TYPE']).to eq 'G'
      end

      context 'unofficial room shares' do
        let(:room_share) { subject.select{ |row| row['CROSS_LISTED_NAME'] == 'MATH 223A, STAT 206A LEC 001' } }
        context 'department participating' do
          let(:math_included) { true }
          it 'reports room shares' do
            expect(room_share.count).to eq 2
            expect(room_share).to all include({'CROSS_LISTED_FLAG' => 'RM SHARE'})
          end
        end
        context 'department not participating' do
          let(:math_included) { false }
          it { expect(room_share).to be_empty }
        end
      end

      context 'supplemental data overrides' do
        let(:supplemental_courses_csv) { File.read Rails.root.join('fixtures', 'oec', 'supplemental_sources_courses.csv') }

        it 'overrides evaluation types in matching rows only' do
          subject.each do |row|
            if row['DEPT_NAME'] == 'STAT' and row['INSTRUCTION_FORMAT'] == 'LEC'
              expect(row['EVALUATION_TYPE']).to eq 'LECT'
            elsif row['DEPT_NAME'] == 'STAT' and row['INSTRUCTION_FORMAT'] == 'DIS'
              expect(row['EVALUATION_TYPE']).to eq 'DISC'
            else
              expect(%w(F G)).to include row['EVALUATION_TYPE']
            end
          end
        end
      end
    end

    describe 'expected network operations' do
      subject { Oec::SisImportTask.new(term_code: term_code) }

      let(:today) { '2015-04-01' }
      let(:now) { '092222' }
      let(:logfile) { "#{now}_sis_import_task.log" }
      let(:dept_name) { 'MATH' }
      let(:export_file) { "#{dept_name}.csv" }

      let(:imports_today_folder) { mock_google_drive_item today }
      let(:reports_today_folder) { mock_google_drive_item today }

      before do
        allow(DateTime).to receive(:now).and_return DateTime.strptime("#{today} #{now}", '%F %H%M%S')
        allow(Oec::CourseCode).to receive(:by_dept_code).and_return({dept_name => fake_code_mapping})
      end

      it 'should upload a department csv and a log file' do
        expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder)
          .with(today, anything, anything)
          .and_return(imports_today_folder, reports_today_folder)
        expect(fake_remote_drive).to receive(:check_conflicts_and_upload)
          .with(kind_of(Oec::Worksheet), dept_name, (Oec::Worksheet), imports_today_folder, anything)
          .and_return mock_google_drive_item(dept_name)
        expect(fake_remote_drive).to receive(:check_conflicts_and_upload)
          .with(kind_of(Pathname), logfile, 'text/plain', reports_today_folder, anything)
          .and_return mock_google_drive_item(logfile)
        subject.run
      end
    end
  end

  describe 'cross-listed name generation' do
    let(:course) { {'CROSS_LISTED_CCNS' => course_codes.keys.join(',') } }
    subject do
      task.set_cross_listed_values([ course ], course_codes)
      course['CROSS_LISTED_NAME']
    end

    context 'departments sharing catalog id and section code' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'}
        }
      end
      it { should eq 'MATH/STAT C51 LEC 001' }
    end

    context 'departments sharing catalog id but not section code' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '003'}
        }
      end
      it { should eq 'MATH C51 LEC 001, STAT C51 LEC 003' }
    end

    context 'departments sharing section code but not catalog id' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C151', 'instruction_format' => 'LEC', 'section_num' => '001'}
        }
      end
      it { should eq 'MATH C51, STAT C151 LEC 001' }
    end

    context 'no shared identifiers between departments' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C151', 'instruction_format' => 'COL', 'section_num' => '001'}
        }
      end
      it { should eq 'MATH C51 LEC 001, STAT C151 COL 001' }
    end

    context 'cross-listings within single department' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C151', 'instruction_format' => 'LEC', 'section_num' => '001'}
        }
      end
      it { should eq 'MATH C51, C151 LEC 001' }
    end

    context 'multiple cross-listings' do
      let(:course_codes) do
        {
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'MATH', 'catalog_id' => 'C151', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C51', 'instruction_format' => 'LEC', 'section_num' => '001'},
          random_id => {'dept_name' => 'STAT', 'catalog_id' => 'C151', 'instruction_format' => 'VOL', 'section_num' => '001'}
        }
      end
      it { should eq 'MATH/STAT C51, MATH C151 LEC 001, STAT C151 VOL 001' }
    end
  end

  context 'department-specific filters' do
    let(:null_sheets_manager) { double.as_null_object }
    before(:each) { allow(Oec::RemoteDrive).to receive(:new).and_return null_sheets_manager }

    it 'filters by course-code department names' do
      expect(Oec::CourseCode).to receive(:by_dept_code).with(dept_name: %w(BIOLOGY MCELLBI)).and_return({})
      Oec::SisImportTask.new(term_code: term_code, dept_names: 'BIOLOGY MCELLBI').run
    end

    it 'filters by department codes' do
      expect(Oec::CourseCode).to receive(:by_dept_code).with(dept_code: %w(IBIBI IMMCB)).and_return({})
      Oec::SisImportTask.new(term_code: term_code, dept_codes: 'IBIBI IMMCB').run
    end
  end

end
