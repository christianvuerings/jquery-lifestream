require "spec_helper"

describe Canvas::TermEnrollmentsCsv do

  let(:frozen_moment_in_time) { Time.at(1388563200) }
  let(:current_sis_term_ids) { ["TERM:2013-D", "TERM:2014-B"] }
  let(:export_dir) { subject.instance_eval { @export_dir } }

  # Define example Section Report CSV response for stubbing
  let(:sections_report_csv_header_string) { "canvas_section_id,section_id,canvas_course_id,course_id,name,status,start_date,end_date,canvas_account_id,account_id" }
  let(:sections_report_csv_string) do
    [
      sections_report_csv_header_string,
      "20,SEC:2014-D-25123,24,CRS:COMPSCI-9D-2014-D,COMPSCI 9D SLF 001,active,,,36,ACCT:COMPSCI",
      "19,SEC:2014-D-25124,24,CRS:COMPSCI-9D-2014-D,COMPSCI 9D SLF 002,active,,,36,ACCT:COMPSCI",
      "21,SEC:2014-D-25125,24,,COMPSCI 9D SLF 003,active,,,36,ACCT:COMPSCI",
      "22,,24,CRS:COMPSCI-9D-2014-D,COMPSCI 9D SLF 003,active,,,36,ACCT:COMPSCI",
    ].join("\n")
  end
  let(:sections_report_csv) { CSV.parse(sections_report_csv_string, :headers => :first_row) }
  let(:empty_sections_report_csv) { CSV.parse(sections_report_csv_header_string + "\n", :headers => :first_row) }

  # Define example Section Enrollment API responses for stubbing
  let(:section_enrollment1) do
    {"course_id"=>24, "course_section_id"=>20, "type"=>"StudentEnrollment", "user_id"=>165, "role"=>"StudentEnrollment", "sis_import_id"=>185, "sis_course_id"=>"CRS:COMPSCI-9D-2014-D", "course_integration_id"=>nil, "sis_section_id"=>"SEC:2014-D-25123", "user"=>{ "sis_login_id"=>"1000123"}}
  end
  let(:section_enrollment2) do
    {"course_id"=>24, "course_section_id"=>19, "type"=>"StudentEnrollment", "user_id"=>166, "role"=>"StudentEnrollment", "sis_import_id"=>nil, "sis_course_id"=>"CRS:COMPSCI-9D-2014-D", "course_integration_id"=>nil, "sis_section_id"=>"SEC:2014-D-25124", "user"=>{ "sis_login_id"=>"1000124" }}
  end
  let(:section_enrollment3) do
    {"course_id"=>24, "course_section_id"=>21, "type"=>"StudentEnrollment", "user_id"=>167, "role"=>"StudentEnrollment", "sis_import_id"=>185, "sis_course_id"=>"CRS:COMPSCI-9D-2014-D", "course_integration_id"=>nil, "sis_section_id"=>"SEC:2014-D-25125", "user"=>{ "sis_login_id"=>"1000125" }}
  end
  let(:section_enrollment4) do
    {"course_id"=>24, "course_section_id"=>22, "type"=>"StudentEnrollment", "user_id"=>168, "role"=>"StudentEnrollment", "sis_import_id"=>185, "sis_course_id"=>"CRS:COMPSCI-9D-2014-D", "course_integration_id"=>nil, "sis_section_id"=>"SEC:2014-D-25126", "user"=>{ "sis_login_id"=>"1000126" }}
  end

  # Define example CSV file contents for stubbing
  let(:section_enrollments_csv_header_string) { 'canvas_section_id,sis_section_id,canvas_user_id,sis_login_id,role,sis_import_id' }
  let(:term1_section_enrollments_csv_string) do
    [
      section_enrollments_csv_header_string,
      '1412606,SEC:2014-C-25128,4906376,7977,StudentEnrollment,101',
      '1412606,SEC:2014-C-25128,4906377,7978,StudentEnrollment,101',
      '1412607,SEC:2014-C-25129,4906376,7977,StudentEnrollment,',
      '1412607,SEC:2014-C-25129,4906377,7978,StudentEnrollment,101',
    ].join("\n")
  end
  let(:term2_section_enrollments_csv_string) do
    [
      section_enrollments_csv_header_string,
      '1413864,SEC:2014-C-24111,4906376,7977,StudentEnrollment,101',
      '1413864,SEC:2014-C-24111,4906377,7978,StudentEnrollment,101',
      '1413865,SEC:2014-C-24112,4906376,7977,StudentEnrollment,101',
      '1413865,SEC:2014-C-24112,4906377,7978,StudentEnrollment,',
    ].join("\n")
  end
  let(:term1_sections_report_csv) { CSV.parse(term1_section_enrollments_csv_string, :headers => :first_row) }
  let(:term2_sections_report_csv) { CSV.parse(term2_section_enrollments_csv_string, :headers => :first_row) }

  let(:expected_term1_filepath) { "#{export_dir}/canvas-2014-01-01-TERM_2013-D-term-enrollments-export.csv" }
  let(:expected_term2_filepath) { "#{export_dir}/canvas-2014-01-01-TERM_2014-B-term-enrollments-export.csv" }

  before do
    allow(Canvas::Proxy).to receive(:current_sis_term_ids).and_return(["TERM:2013-D", "TERM:2014-B"])

    # set static times for consistent testing output
    allow(Time).to receive(:now).and_return(frozen_moment_in_time)
    allow(DateTime).to receive(:now).and_return(frozen_moment_in_time.to_datetime)

    # stub behavior for Canvas::SectionsReport
    allow_any_instance_of(Canvas::SectionsReport).to receive(:get_csv).and_return(sections_report_csv)

    # stub behavior for Canvas::SectionEnrollments
    section_enrollments_worker_1 = double(:list_enrollments => [section_enrollment1])
    section_enrollments_worker_2 = double(:list_enrollments => [section_enrollment2])
    section_enrollments_worker_3 = double(:list_enrollments => [section_enrollment3])
    section_enrollments_worker_4 = double(:list_enrollments => [section_enrollment4])
    allow(Canvas::SectionEnrollments).to receive(:new).with(:section_id => '20').and_return(section_enrollments_worker_1)
    allow(Canvas::SectionEnrollments).to receive(:new).with(:section_id => '19').and_return(section_enrollments_worker_2)
    allow(Canvas::SectionEnrollments).to receive(:new).with(:section_id => '21').and_return(section_enrollments_worker_3)
    allow(Canvas::SectionEnrollments).to receive(:new).with(:section_id => '22').and_return(section_enrollments_worker_4)

    # setup default values for global canvas synchronization settings
    Canvas::Synchronization.create(:last_guest_user_sync => 1.weeks.ago.utc)
    Canvas::Synchronization.get.update(:latest_term_enrollment_csv_set => (frozen_moment_in_time - 1.day))
  end

  after do
    delete_files_if_exists([expected_term1_filepath, expected_term2_filepath])
    Canvas::Synchronization.delete_all
  end

  describe "#initialize" do
    it "sets export directory to Canvas settings value" do
      result = subject.instance_eval { @export_dir }
      expect(result).to eq Settings.canvas_proxy.export_directory
    end
  end

  describe "#term_enrollments_csv_filepaths" do
    it "provides files for current date by default" do
      csv_filepaths = subject.term_enrollments_csv_filepaths
      expect(csv_filepaths).to be_an_instance_of Hash
      expect(csv_filepaths['TERM:2013-D']).to eq "#{export_dir}/canvas-2014-01-01-TERM_2013-D-term-enrollments-export.csv"
      expect(csv_filepaths['TERM:2014-B']).to eq "#{export_dir}/canvas-2014-01-01-TERM_2014-B-term-enrollments-export.csv"
    end

    it "provides files for date specified" do
      csv_filepaths = subject.term_enrollments_csv_filepaths(Time.at(1388863600))
      expect(csv_filepaths).to be_an_instance_of Hash
      expect(csv_filepaths['TERM:2013-D']).to eq "#{export_dir}/canvas-2014-01-04-TERM_2013-D-term-enrollments-export.csv"
      expect(csv_filepaths['TERM:2014-B']).to eq "#{export_dir}/canvas-2014-01-04-TERM_2014-B-term-enrollments-export.csv"
    end
  end

  describe "#enrollment_csv_filepath" do
    it "returns expected filepath for date and term_id provided" do
      result = subject.enrollment_csv_filepath(Time.now, 'TERM:2014-D')
      expect(result).to eq "#{export_dir}/canvas-2014-01-01-TERM_2014-D-term-enrollments-export.csv"
    end
  end

  describe "#latest_term_enrollment_set_date" do
    let(:sync_setting) { double(:sync_setting, :latest_term_enrollment_csv_set => frozen_moment_in_time.in_time_zone) }
    it "returns the date for the latest CSV term enrollments set" do
      allow(Canvas::Synchronization).to receive(:get).and_return(sync_setting)
      result = subject.latest_term_enrollment_set_date
      expect(result).to be_an_instance_of Date
      expect(result).to eq frozen_moment_in_time.to_date
    end

    it "obtains the latest set date only once" do
      expect(Canvas::Synchronization).to receive(:get).once.and_return(sync_setting)
      result_1 = subject.latest_term_enrollment_set_date
      result_2 = subject.latest_term_enrollment_set_date
      expect(result_1).to be_an_instance_of Date
      expect(result_2).to be_an_instance_of Date
      expect(result_1).to eq frozen_moment_in_time.to_date
      expect(result_2).to eq frozen_moment_in_time.to_date
    end
  end

  describe "#export_enrollments_to_csv_set" do
    it "generates csv exports for each term" do
      expect(subject).to receive(:populate_term_csv_file).and_return(nil).twice
      subject.export_enrollments_to_csv_set
    end

    it "updates tracking timestamp when finished exporting enrollments to csv set" do
      subject.export_enrollments_to_csv_set
      sync_settings = Canvas::Synchronization.get
      expect(sync_settings.latest_term_enrollment_csv_set).to eq frozen_moment_in_time.to_datetime.in_time_zone
    end
  end

  describe "#populate_term_csv_file" do
    context "when sections report is empty" do
      before { allow_any_instance_of(Canvas::SectionsReport).to receive(:get_csv).and_return(empty_sections_report_csv) }
      it "should escape execution" do
        enrollments_csv = subject.make_enrollment_export_csv("#{export_dir}/canvas-2014-01-01-TERM_2014-D-term-enrollments-export.csv")
        expect_any_instance_of(Canvas::SectionEnrollments).to_not receive(:new)
        subject.populate_term_csv_file(current_sis_term_ids[0], enrollments_csv)
      end
    end

    it "populates csv export for term specified" do
      enrollments_csv = subject.make_enrollment_export_csv("#{export_dir}/canvas-2014-01-01-TERM_2014-D-term-enrollments-export.csv")
      subject.populate_term_csv_file(current_sis_term_ids[0], enrollments_csv)
      enrollments_csv.close
      enrollments_csv = CSV.read(enrollments_csv.path, {headers: true})
      expect(enrollments_csv.count).to eq 4
      expect(enrollments_csv[0]['canvas_section_id']).to eq '20'
      expect(enrollments_csv[1]['canvas_section_id']).to eq '19'
      expect(enrollments_csv[2]['canvas_section_id']).to eq '21'
      expect(enrollments_csv[3]['canvas_section_id']).to eq '22'
      expect(enrollments_csv[0]['sis_section_id']).to eq "SEC:2014-D-25123"
      expect(enrollments_csv[1]['sis_section_id']).to eq "SEC:2014-D-25124"
      expect(enrollments_csv[2]['sis_section_id']).to eq "SEC:2014-D-25125"
      expect(enrollments_csv[3]['sis_section_id']).to eq "SEC:2014-D-25126"
      expect(enrollments_csv[0]['canvas_user_id']).to eq '165'
      expect(enrollments_csv[1]['canvas_user_id']).to eq '166'
      expect(enrollments_csv[2]['canvas_user_id']).to eq '167'
      expect(enrollments_csv[3]['canvas_user_id']).to eq '168'
      expect(enrollments_csv[0]['sis_login_id']).to eq '1000123'
      expect(enrollments_csv[1]['sis_login_id']).to eq '1000124'
      expect(enrollments_csv[2]['sis_login_id']).to eq '1000125'
      expect(enrollments_csv[3]['sis_login_id']).to eq '1000126'
      expect(enrollments_csv[0]['sis_import_id']).to eq '185'
      expect(enrollments_csv[1]['sis_import_id']).to eq nil
      expect(enrollments_csv[2]['sis_import_id']).to eq '185'
      expect(enrollments_csv[3]['sis_import_id']).to eq '185'
      expect(enrollments_csv[0]['role']).to eq 'StudentEnrollment'
      expect(enrollments_csv[1]['role']).to eq 'StudentEnrollment'
    end
  end

  describe "#make_enrollment_export_csv" do
    it "returns CSV file object with headers initialized" do
      export_csv = subject.make_enrollment_export_csv("#{export_dir}/canvas-2014-01-01-TERM_2013-D-term-enrollments-export.csv")
      expect(export_csv).to be_an_instance_of CSV
      export_csv << [5,'SEC:2013-D-26109',165,'23828759','StudentEnrollment',185]
      expect(export_csv.headers).to eq ["canvas_section_id", "sis_section_id", "canvas_user_id", "sis_login_id", "role", "sis_import_id"]
      export_csv.close
    end
  end

  describe "#load_current_term_enrollments" do
    before do
      allow(CSV).to receive(:read).with(expected_term1_filepath, {headers: true}).and_return(term1_sections_report_csv)
      allow(CSV).to receive(:read).with(expected_term2_filepath, {headers: true}).and_return(term2_sections_report_csv)
    end

    it "loads canvas section enrollments hash from latest CSV set" do
      subject.export_enrollments_to_csv_set
      result = subject.load_current_term_enrollments
      expect(result).to be_an_instance_of Hash
      expect(result.keys).to eq ["1412606", "1412607", "1413864", "1413865"]
      result.each do |canvas_section_id,csv_rows|
        expect(csv_rows).to be_an_instance_of Array
        expect(csv_rows.count).to eq 2
        expect(csv_rows[0]).to be_an_instance_of CSV::Row
        expect(csv_rows[1]).to be_an_instance_of CSV::Row
      end
      expect(result['1412606'][0]['sis_section_id']).to eq 'SEC:2014-C-25128'
      expect(result['1412606'][1]['sis_section_id']).to eq 'SEC:2014-C-25128'
      expect(result['1412606'][0]['canvas_user_id']).to eq '4906376'
      expect(result['1412606'][1]['canvas_user_id']).to eq '4906377'
      expect(result['1413865'][0]['sis_section_id']).to eq 'SEC:2014-C-24112'
      expect(result['1413865'][1]['sis_section_id']).to eq 'SEC:2014-C-24112'
      expect(result['1413865'][0]['canvas_user_id']).to eq '4906376'
      expect(result['1413865'][1]['canvas_user_id']).to eq '4906377'
    end
  end

  describe "#cached_canvas_section_enrollments" do
    before do
      allow(CSV).to receive(:read).with(expected_term1_filepath, {headers: true}).and_return(term1_sections_report_csv)
      allow(CSV).to receive(:read).with(expected_term2_filepath, {headers: true}).and_return(term2_sections_report_csv)
    end

    it "does not load current term enrollments if already present" do
      expect(subject).to_not receive(:load_current_term_enrollments)
      subject.instance_eval { @canvas_section_id_enrollments = {'19' => ['enrollment1', 'enrollment2']} }
      result = subject.cached_canvas_section_enrollments('19')
      expect(result).to eq ['enrollment1', 'enrollment2']
    end

    it "returns enrollments for canvas section id specified" do
      subject.export_enrollments_to_csv_set
      result = subject.cached_canvas_section_enrollments('1413864')
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]).to be_an_instance_of CSV::Row
      expect(result[1]).to be_an_instance_of CSV::Row
      expect(result[0]['canvas_section_id']).to eq "1413864"
      expect(result[1]['canvas_section_id']).to eq "1413864"
      expect(result[0]['sis_section_id']).to eq "SEC:2014-C-24111"
      expect(result[1]['sis_section_id']).to eq "SEC:2014-C-24111"
      expect(result[0]['canvas_user_id']).to eq "4906376"
      expect(result[1]['canvas_user_id']).to eq "4906377"
      expect(result[0]['sis_login_id']).to eq "7977"
      expect(result[1]['sis_login_id']).to eq "7978"
      expect(result[0]['role']).to eq "StudentEnrollment"
      expect(result[1]['role']).to eq "StudentEnrollment"
      expect(result[0]['sis_import_id']).to eq "101"
      expect(result[1]['sis_import_id']).to eq "101"
    end
  end

end
