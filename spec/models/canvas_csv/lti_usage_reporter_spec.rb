describe CanvasCsv::LtiUsageReporter do
  let(:sis_term_id) {'TERM:2015-D'}
  # Keyed to the relevant static JSON feeds in "fixtures".
  let(:fake_accounts_csv) do
    fake_csv = <<-FAKE_CSV
canvas_account_id,account_id,canvas_parent_id,parent_account_id,name,status
129409,ACCT:COURSES,90242,,Courses,active
129410,ACCT:OFFICIAL_COURSES,129409,ACCT:COURSES,Official Courses,active
129069,,129410,ACCT:OFFICIAL_COURSES,COM LIT,active
129091,ACCT:EWMBA,128848,ACCT:HAAS,EWMBA,active
128848,ACCT:HAAS,129410,ACCT:OFFICIAL_COURSES,HAAS,active
    FAKE_CSV
    CSV.parse(fake_csv, {headers: true})
  end

  # Keyed to the relevant static JSON feeds in "fixtures". No matching feed is available for the unpublished
  # course.
  let(:fake_courses_csv) do
    fake_csv = <<-FAKE_CSV
canvas_course_id,course_id,short_name,long_name,canvas_account_id,account_id,canvas_term_id,term_id,status,start_date,end_date
1234567,,COM LIT ABC,Some unofficial course,129069,,5487,TERM:2015-D,active,,
1234568,,TIL MOC,Some unpublished course,129069,,5487,TERM:2015-D,unpublished,,
8876542,CRS:FOODSERV-10,FOODSERV 10,Mushroom Pizza,129091,ACCT:EWMBA,5487,TERM:2015-D,active,,
9876543,CRS:FOODSERV-2,FOODSERV 2,Cheese Pizza,129091,ACCT:EWMBA,5487,TERM:2015-D,active,,
    FAKE_CSV
    CSV.parse(fake_csv, {headers: true})
  end
  let(:fake_courses_reporter) { instance_double(Canvas::Report::Courses) }
  let(:summary_report) { [] }
  let(:courses_report) { [] }

  subject { described_class.new(sis_term_id) }

  before do
    allow(Canvas::Report::Subaccounts).to receive(:new).with({account_id: Settings.canvas_proxy.account_id}).and_return(double(
          get_csv: fake_accounts_csv
        ))
    allow(Canvas::Report::Courses).to receive(:new).with({account_id: Settings.canvas_proxy.account_id}).and_return(fake_courses_reporter)
    allow(fake_courses_reporter).to receive(:get_csv).with(sis_term_id).and_return(fake_courses_csv)

    allow(Canvas::CourseTeachers).to receive(:new) do |options|
      list = case options[:course_id]
        when '8876542'
          [
            {
              'id' => 9898898,
              'name' => 'Fitzi Ritz',
              'email' => 'fitzi@example.com'
            }
          ]
        when '1234567'
          []
        else
          [
            {
              'id' => 9898899,
              'name' => 'Nancy Ritz',
              'email' => 'nancy@example.com'
            }
          ]
      end
      instance_double(Canvas::CourseTeachers, full_teachers_list: {statusCode: 200, body: list})
    end

    allow(CSV).to receive(:open) do |filename, mode, options|
      if mode == 'wb'
        if filename.include? 'summary'
          summary_report
        elsif filename.include? 'courses'
          courses_report
        end
      end
    end
    allow(summary_report).to receive(:close)
    allow(courses_report).to receive(:close)
  end

  describe '#summary_report' do
    it 'includes a UC Berkeley non-course-navigation app' do
      subject.run
      tool_row = summary_report.select {|row| row['URL'].end_with? 'site_creation'}.first
      expect(tool_row['Accounts']).to eq Settings.canvas_proxy.account_id
      expect(tool_row['Courses Visible'].to_s).to eq 'N/A'
    end
    it 'includes a hidden course app' do
      subject.run
      tool_row = summary_report.select {|row| row['URL'].end_with? 'course_add_user'}.first
      expect(tool_row['Courses Visible'].to_s).to eq '0'
    end
    it 'includes a subaccount app' do
      subject.run
      tool_row = summary_report.select {|row| row['URL'].end_with? 'rosters'}.first
      expect(tool_row['Courses Visible'].to_s).to eq '3'
    end
    it 'includes a course-defined app' do
      subject.run
      tool_row = summary_report.select {|row| row['URL'].include? 'pizza'}.first
      expect(tool_row['Accounts']).to be_empty
      expect(tool_row['Courses Visible'].to_s).to eq '2'
    end
    it 'includes an app with no explicit URL' do
      subject.run
      tool_row = summary_report.select {|row| row['Tool'] == 'W. W. Norton'}.first
      expect(tool_row['URL']).to be_present
      expect(tool_row['Courses Visible'].to_s).to eq '1'
    end
    it 'keeps Excel from interpreting a list of account IDs as one spectacularly large number' do
      subject.tool_url_to_summary = {
        'acme.com' => {label: 'Acme Quality', url: 'acme.com', accounts: [12345,67890], nbr_courses_visible: 13}
      }
      subject.generate_summary_report
      expect(summary_report.first['Accounts']).to eq '12345, 67890'
    end
  end

  describe '#courses_report' do
    it 'includes course names' do
      subject.run
      courses_report.each do |row|
        expect(row['Name']).to be_present
      end
    end
    it 'excludes the standard external apps' do
      subject.run
      tool_rows = courses_report.select {|row| row['Tool'] == 'Official Sections'}
      expect(tool_rows).to be_blank
    end
    it 'includes apps added at the course level' do
      subject.run
      tool_rows = courses_report.select {|row| row['Tool'] == 'Pizza'}
      expect(tool_rows.length).to eq 2
    end
    it 'includes course sites without an SIS ID'do
      subject.run
      tool_rows = courses_report.select {|row| row['Course URL'].end_with? '1234567'}
      expect(tool_rows).to be_present
    end
    it 'excludes unpublished courses' do
      subject.run
      tool_rows = courses_report.select {|row| row['Course URL'].end_with? '1234568'}
      expect(tool_rows).to be_blank
    end
    it 'includes teacher name and email if available' do
      subject.run
      tool_row = courses_report.select {|row| row['Course URL'].end_with? '8876542'}.first
      expect(tool_row['Teacher']).to eq 'Fitzi Ritz'
      expect(tool_row['Email']).to eq 'fitzi@example.com'
      tool_row = courses_report.select {|row| row['Course URL'].end_with? '9876543'}.first
      expect(tool_row['Teacher']).to eq 'Nancy Ritz'
      expect(tool_row['Email']).to eq 'nancy@example.com'
    end
    it 'includes teacherless sites' do
      subject.run
      tool_row = courses_report.select {|row| row['Course URL'].end_with? '1234567'}.first
      expect(tool_row['Teacher']).to be_blank
      expect(tool_row['Email']).to be_blank
    end
    it 'includes non-Course-Navigation apps which were explicitly added to the course' do
      subject.run
      tool_row = courses_report.select {|row| row['Tool'] == 'W. W. Norton'}.first
      expect(tool_row['Course URL']).to be_present
    end
  end

end
