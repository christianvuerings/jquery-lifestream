include OecSpecHelper

describe Oec::CoursesImportTask do

  let(:fake_sheets_manager) { double() }
  let(:term_code) { '2015-B' }

  def load_fixture_courses
    @cross_listed_queries = {}
    cross_listed_names = []
    courses_by_ccn = {}
    Dir.glob(Rails.root.join 'fixtures', 'oec', 'courses_for_dept_*.json').each do |json|
      courses = JSON.parse(File.read json)
      @courses_query = courses if json.include? dept_name.gsub(' ', '_')
      courses.each do |course_info|
        courses_by_ccn[course_info['course_cntl_num'].to_i] = course_info
        cross_listed_names << course_info['cross_listed_name'] if json.include? dept_name.gsub(' ', '_')
      end
    end
    cross_listed_names.reject(&:blank?).each do |cross_listed_name|
      @cross_listed_queries[cross_listed_name] = cross_listed_name.split(',').map { |ccn| courses_by_ccn[ccn.to_i] }
    end
  end

  def get_fake_code_mapping(dept_name)
    [Oec::CourseCode.new(dept_name: dept_name, catalog_id: nil, dept_code: dept_name, include_in_oec: true)]
  end

  before(:each) do
    allow(GoogleApps::SheetsManager).to receive(:new).and_return fake_sheets_manager
    load_fixture_courses
    @fake_code_mapping = get_fake_code_mapping(dept_name)
    expect(Oec::Queries).to receive(:courses_for_codes).with(term_code, @fake_code_mapping).exactly(1).times.and_return @courses_query
    @cross_listed_queries.each do |k, v|
      expect(Oec::Queries).to receive(:courses_for_cntl_nums).with(term_code, k).exactly(1).times.and_return v
    end
  end

  describe 'CSV export structure' do
    subject do
      task = Oec::CoursesImportTask.new(term_code: term_code)
      courses = Oec::Courses.new(Rails.root.join('tmp/oec'), dept_code: dept_name)
      task.import_courses(courses, @fake_code_mapping)
      courses.export
      CSV.read(courses.output_filename).slice(1..-1).map { |row| Hash[ courses.headers.zip(row) ]}
    end

    let(:course_id_column) { subject.map { |row| row['COURSE_ID'] } }

    shared_examples 'expected CSV structure' do
      it { expect(course_id_column).to contain_exactly(*expected_ids) }
      it 'should include dept_form only for non-crosslisted courses' do
        subject.each do |row|
          if row['CROSS_LISTED_FLAG'].present?
            expect(row['DEPT_FORM']).to be_nil
          else
            expect(row['DEPT_FORM']).to be_present
          end
        end
      end
    end

    context 'ANTHRO dept' do
      let(:dept_name) { 'ANTHRO' }
      let(:expected_ids) { %w(2015-B-02567) }
      include_examples 'expected CSV structure'
    end

    context 'MATH dept' do
      let(:dept_name) { 'MATH' }
      let(:expected_ids) { %w(2015-B-87672 2015-B-87675 2015-B-87673) }
      include_examples 'expected CSV structure'
    end

    context 'POL SCI dept' do
      let(:dept_name) { 'POL SCI' }
      let(:expected_ids) { %w(2015-B-87690 2015-B-72199 2015-B-71523) }
      include_examples 'expected CSV structure'
    end

    context 'STAT dept' do
      let(:dept_name) { 'STAT' }
      let(:expected_ids) { %w(2015-B-87673 2015-B-54432 2015-B-54441 2015-B-72199 2015-B-87691 2015-B-87693) }
      include_examples 'expected CSV structure'
      it 'should not include course supervisor assignments' do
        expect(subject.map{ |row| row['INSTRUCTOR_FUNC'] }).not_to include '3'
      end
    end
  end

  describe 'expected network operations' do
    subject { Oec::CoursesImportTask.new(term_code: term_code) }

    let(:today) { '2015-04-01' }
    let(:now) { '092222' }
    let(:logfile) { "#{now}_courses_import_task.log" }
    let(:dept_name) { 'MATH' }
    let(:export_file) { "#{dept_name}.csv" }


    before do
      allow(DateTime).to receive(:now).and_return DateTime.strptime("#{today} #{now}", '%F %H%M%S')
      allow(Oec::CourseCode).to receive(:included_by_dept_code).and_return({dept_name => @fake_code_mapping})
    end

    it 'should upload a department csv and a log file' do
      expect_folder_lookup(term_code, 'root')
      expect_folder_lookup('imports', term_code)
      expect_folder_lookup(today, 'imports')
      expect_folder_lookup('reports', term_code)
      expect_folder_lookup(today, 'reports')
      expect_file_upload(logfile, today, 'text/plain')
      expect_sheet_upload(export_file, today)
      subject.run
    end
  end
end
