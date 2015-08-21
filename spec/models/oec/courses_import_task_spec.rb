describe Oec::CoursesImportTask do

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

  def mock_file(file_name)
    if file_name == 'root'
      double(title: nil, id: 'root')
    else
      double(title: file_name, id: "#{file_name}_id")
    end
  end

  def get_fake_code_mapping(dept_name)
    [Oec::CourseCode.new(dept_name: dept_name, catalog_id: nil, dept_code: dept_name, include_in_oec: true)]
  end

  before(:each) do
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
      CSV.read(courses.output_filename).map { |row| row[0] }
    end

    context 'reading ANTHRO csv file' do
      let(:dept_name) { 'ANTHRO' }
      it { should contain_exactly('COURSE_ID', '2015-B-02567') }
    end

    context 'reading MATH csv file' do
      let(:dept_name) { 'MATH' }
      it { should contain_exactly('COURSE_ID', '2015-B-87672', '2015-B-87675', '2015-B-87673') }
    end

    context 'reading POL SCI csv file' do
      let(:dept_name) { 'POL SCI' }
      it { should contain_exactly('COURSE_ID', '2015-B-87690', '2015-B-72199', '2015-B-71523') }
    end

    context 'reading STAT csv file' do
      let(:dept_name) { 'STAT' }
      it { should contain_exactly('COURSE_ID', '2015-B-87673', '2015-B-54432', '2015-B-54441', '2015-B-72199', '2015-B-87691', '2015-B-87693') }
    end
  end

  describe 'expected network operations' do
    subject { Oec::CoursesImportTask.new(term_code: term_code) }

    let(:fake_drive_manager) { double() }
    let(:today) { '2015-04-01' }
    let(:now) { '092222' }
    let(:logfile) { "#{now}_courses_import_task.log" }
    let(:dept_name) { 'MATH' }
    let(:export_file) { "#{dept_name}.csv" }

    def expect_file_upload(file_name, parent_name, type)
      expect(fake_drive_manager).to receive(:find_items_by_title)
        .with(file_name, parent_id: mock_file(parent_name).id)
        .and_return []
      expect(fake_drive_manager).to receive(:upload_file)
        .with(file_name, '', mock_file(parent_name).id, type, Rails.root.join('tmp', 'oec', file_name).to_s)
        .and_return(mock_file(file_name))
    end

    def expect_folder_lookup(folder_name, parent_name)
      expect(fake_drive_manager).to receive(:find_folders_by_title)
        .with(folder_name, mock_file(parent_name).id)
        .at_least(1).times
        .and_return([mock_file(folder_name)])
    end

    before do
      allow(DateTime).to receive(:now).and_return DateTime.strptime("#{today} #{now}", '%F %H%M%S')
      allow(GoogleApps::DriveManager).to receive(:new).and_return fake_drive_manager
      allow(Oec::CourseCode).to receive(:included_by_dept_code).and_return({dept_name => @fake_code_mapping})
    end

    it 'should upload a department csv and a log file' do
      expect_folder_lookup(term_code, 'root')
      expect_folder_lookup('imports', term_code)
      expect_folder_lookup(today, 'imports')
      expect_folder_lookup('reports', term_code)
      expect_folder_lookup(today, 'reports')
      expect_file_upload(logfile, today, 'text/plain')
      expect_file_upload(export_file, today, 'text/csv')
      subject.run
    end
  end
end
