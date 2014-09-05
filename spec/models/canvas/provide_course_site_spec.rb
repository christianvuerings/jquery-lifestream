require "spec_helper"

describe Canvas::ProvideCourseSite do

  let(:uid)   { rand(99999).to_s }
  let(:site_name) { 'Introduction to Computer Programming for Scientists and Engineers' }
  let(:site_course_code) { 'ENGIN 7' }
  subject     { Canvas::ProvideCourseSite.new(uid) }

  #####################################
  # Class Methods

  describe ".unique_job_id" do
    it "returns unique job id based on current time" do
      current_time = Time.at(1383330151.057)
      expect(Time).to receive(:now) { current_time }
      result = Canvas::ProvideCourseSite.unique_job_id
      expect(result).to eq "1383330151057"
    end
  end

  describe ".find" do
    it "returns the current job object from global storage" do
      job_state = { status: 'Completed' }
      Rails.cache.write('canvas.courseprovision.1234.123456789', job_state, expires_in: 5.seconds.to_i, raw: true)
      result = Canvas::ProvideCourseSite.find('canvas.courseprovision.1234.123456789')
      expect(result).to eq job_state
    end

    it "returns nil if job state not found" do
      result = Canvas::ProvideCourseSite.find('canvas.courseprovision.1234.123456789')
      result.should be_nil
    end
  end

  #####################################
  # Instance Methods

  describe "#initialize" do
    it "raises exception if uid is not a String" do
      expect { Canvas::ProvideCourseSite.new(1234) }.to raise_error(ArgumentError, "uid must be a String")
    end

    its(:uid)       { should eq uid }
    its(:status)    { should eq 'New' }

    it "initializes the completed steps array" do
      expect(subject.instance_eval { @completed_steps }).to eq []
    end

    it "initializes the error array" do
      expect(subject.instance_eval { @errors }).to eq []
    end

    it "initializes the import data hash" do
      expect(subject.instance_eval { @import_data }).to be_an_instance_of Hash
      expect(subject.instance_eval { @import_data }).to eq({})
    end

    it "initializes with unique cache key" do
      Canvas::ProvideCourseSite.stub(:unique_job_id).and_return('1383330151057')
      expect(subject.cache_key).to eq "canvas.courseprovision.#{uid}.1383330151057"
    end
  end

  describe "#create_course_site" do
    before do
      allow(subject).to receive(:prepare_users_courses_list).and_return(true)
      allow(subject).to receive(:identify_department_subaccount).and_return(true)
      allow(subject).to receive(:prepare_course_site_definition).and_return(true)
      allow(subject).to receive(:prepare_section_definitions).and_return(true)
      allow(subject).to receive(:import_course_site).and_return(true)
      allow(subject).to receive(:import_sections).and_return(true)
      allow(subject).to receive(:add_instructor_to_sections).and_return(true)
      allow(subject).to receive(:retrieve_course_site_details).and_return(true)
      allow(subject).to receive(:expire_instructor_sites_cache).and_return(true)
      allow(subject).to receive(:import_enrollments_in_background).and_return(true)
    end

    it "intercepts raised exceptions and updates status" do
      allow(subject).to receive(:import_course_site).and_raise(RuntimeError, "Course site could not be created!")
      expect { subject.create_course_site(site_name, site_course_code, "fall-2013", ["1136", "1204"]) }.to raise_error(RuntimeError, "Course site could not be created!")
      expect(subject.status).to eq "Error"
      errors = subject.instance_eval { @errors }
      expect(errors).to be_an_instance_of Array
      expect(errors[0]).to eq "Course site could not be created!"
    end

    it "makes calls to each step of import in proper order" do
      expect(subject).to receive(:prepare_users_courses_list).ordered.and_return(true)
      expect(subject).to receive(:identify_department_subaccount).ordered.and_return(true)
      expect(subject).to receive(:prepare_course_site_definition).ordered.and_return(true)
      expect(subject).to receive(:prepare_section_definitions).ordered.and_return(true)
      expect(subject).to receive(:import_course_site).ordered.and_return(true)
      expect(subject).to receive(:import_sections).ordered.and_return(true)
      expect(subject).to receive(:add_instructor_to_sections).ordered.and_return(true)
      expect(subject).to receive(:retrieve_course_site_details).ordered.and_return(true)
      expect(subject).to receive(:expire_instructor_sites_cache).ordered.and_return(true)
      expect(subject).to receive(:import_enrollments_in_background).ordered.and_return(true)
      subject.create_course_site(site_name, site_course_code, "fall-2013", ["1136", "1204"])
    end

    it "sets term and ccns for import" do
      subject.create_course_site(site_name, site_course_code, "fall-2013", ["1136", "1204"])
      expect(subject.instance_eval { @import_data['term_slug'] }).to eq "fall-2013"
      expect(subject.instance_eval { @import_data['term'][:yr] }).to eq "2013"
      expect(subject.instance_eval { @import_data['term'][:cd] }).to eq "D"
      expect(subject.instance_eval { @import_data['ccns'] }).to eq ["1136", "1204"]
    end

    it "sets status as completed and saves" do
      subject.create_course_site(site_name, site_course_code, "fall-2013", ["1136", "1204"])
      cached_object = Canvas::ProvideCourseSite.find(subject.job_id)
      expect(cached_object.status).to eq "Completed"
    end
  end

  describe "#prepare_users_courses_list" do
    before do
      subject.instance_eval do
        @import_data['term_slug'] = "fall-2013"
        @import_data['ccns'] = ["1136", "1204"]
      end
      @filtered_courses_list = [
        {
          :course_code=>"COMPSCI 10",
          :dept=>"COMPSCI",
          :slug=>"compsci-10",
          :title=>"The Beauty and Joy of Computing",
          :role=>"Instructor",
          :sections=>[
            {:ccn=>"1136", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:buildingName=>"SODA", :room_number=>"0320", :schedule=>"M 8:00A-9:00A"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]},
            {:ccn=>"1204", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 109", :section_number=>"109", :schedules=>[{:buildingName=>"SODA", :room_number=>"0320", :schedule=>"M 12:00P-1:00P"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]}
          ]
        }
      ]
    end

    it "raises exception if term slug not present in import data set" do
      subject.instance_eval { @import_data['term_slug'] = nil }
      expect { subject.prepare_users_courses_list }.to raise_error(RuntimeError, "Unable to prepare course list. Term code not present.")
    end

    it "raises exception if course control numbers are not present in import data set" do
      subject.instance_eval { @import_data['ccns'] = nil }
      expect { subject.prepare_users_courses_list }.to raise_error(RuntimeError, "Unable to prepare course list. CCNs not present.")
    end

    it "assigns user courses set to import data hash" do
      allow(subject).to receive(:candidate_courses_list).and_return(true)
      expect(subject).to receive(:filter_courses_by_ccns).and_return(@filtered_courses_list)
      subject.prepare_users_courses_list
      assigned_courses = subject.instance_eval { @import_data['courses'] }
      expect(assigned_courses).to be_an_instance_of Array
      expect(assigned_courses.count).to eq 1
      expect(assigned_courses[0]).to be_an_instance_of Hash
      expect(assigned_courses[0][:course_code]).to eq "COMPSCI 10"
    end

    it "lets admins specify CCNs directly" do
      subject.instance_eval { @import_data['is_admin_by_ccns'] = true }
      expect(subject).to_not receive(:candidate_courses_list)
      expect(subject).to_not receive(:filter_courses_by_ccns)
      expect(subject).to receive(:courses_list_from_ccns).and_return(@filtered_courses_list)
      subject.prepare_users_courses_list
    end

    it "updates completed steps list" do
      allow(subject).to receive(:candidate_courses_list).and_return(true)
      expect(subject).to receive(:filter_courses_by_ccns).and_return("user_courses_list")
      subject.prepare_users_courses_list
      expect(subject.instance_eval { @completed_steps }).to eq ["Prepared courses list"]
    end
  end

  describe "#identify_department_subaccount" do
    before do
      allow(subject).to receive(:subaccount_for_department).and_return('ACCT:COMPSCI')
      subject.instance_eval { @import_data['courses'] = [{:course_code => 'ENGIN 7', :dept => 'COMPSCI', :sections => []}] }
    end

    it "raises exception if import courses not present" do
      subject.instance_eval { @import_data['courses'] = nil }
      expect { subject.identify_department_subaccount }.to raise_error(RuntimeError, "Unable identify department subaccount. Course list not loaded or empty.")
    end

    it "adds department id to import data" do
      subject.identify_department_subaccount
      expect(subject.instance_eval { @import_data['subaccount'] }).to eq 'ACCT:COMPSCI'
    end

    it "updates completed steps list" do
      subject.identify_department_subaccount
      expect(subject.instance_eval { @completed_steps }).to eq ["Identified department sub-account"]
    end
  end

  describe "#prepare_course_site_definition" do
    before do
      subject.instance_eval do
        @import_data['term'] = {yr: '2013', cd: 'D', slug: "fall-2013"}
        @import_data['subaccount'] = "ACCT:COMPSCI"
        @import_data['courses'] = [
          {
            :course_code => "MEC ENG 98",
            :slug => "mec_eng-98",
            :dept => 'MEC ENG',
            :title => "Supervised Independent Group Studies",
            :role => "Instructor",
            :sections => [
              { :ccn => rand(99999).to_s, :instruction_format => "GRP", :is_primary_section => true, :section_label => "GRP 015", :section_number => "015" }
            ]
          }
        ]
      end
      course_site_definition = {
        'course_id' => "CRS:MEC_ENG-98-2013-D",
        'short_name' => "MEC ENG 98 GRP 015",
        'long_name' => "Supervised Independent Group Studies",
        'account_id' => "ACCT:COMPSCI",
        'term_id' => "TERM:2013-D",
        'status' => 'active',
      }
      allow(subject).to receive(:generate_course_site_definition).and_return(course_site_definition)
    end

    it "raises exception if course term is not present" do
      subject.instance_eval { @import_data['term'] = nil }
      expect { subject.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Term data is not present.")
    end

    it "raises exception if department subaccount is not present" do
      subject.instance_eval { @import_data['subaccount'] = nil }
      expect { subject.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Department subaccount ID not present.")
    end

    it "raises exception if courses list is not present" do
      subject.instance_eval { @import_data['courses'] = nil }
      expect { subject.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Courses list is not present.")
    end

    it "populates the course site definition" do
      subject.prepare_course_site_definition
      course_site_definition = subject.instance_eval { @import_data['course_site_definition'] }
      expect(course_site_definition).to be_an_instance_of Hash
      expect(course_site_definition['status']).to eq "active"
      expect(course_site_definition['course_id']).to eq "CRS:MEC_ENG-98-2013-D"
      expect(course_site_definition['account_id']).to eq "ACCT:COMPSCI"
      expect(course_site_definition['term_id']).to eq "TERM:2013-D"
      expect(course_site_definition['short_name']).to eq "MEC ENG 98 GRP 015"
      expect(course_site_definition['long_name']).to eq "Supervised Independent Group Studies"
    end

    it "sets the sis course id" do
      subject.prepare_course_site_definition
      sis_course_id = subject.instance_eval { @import_data['sis_course_id'] }
      expect(sis_course_id).to eq "CRS:MEC_ENG-98-2013-D"
    end

    it "sets the course site short name" do
      subject.prepare_course_site_definition
      course_site_short_name = subject.instance_eval { @import_data['course_site_short_name'] }
      expect(course_site_short_name).to eq "MEC ENG 98 GRP 015"
    end

    it "updates completed steps list" do
      subject.prepare_course_site_definition
      expect(subject.instance_eval { @completed_steps }).to eq ["Prepared course site definition"]
    end
  end

  describe "#prepare_section_definitions" do
    before do
      subject.instance_eval do
        @import_data['term'] = {yr: '2013', cd: 'D', slug: "fall-2013"}
        @import_data['sis_course_id'] = "CRS:MEC_ENG-98-2013-D"
        @import_data['courses'] = [
          {
            :course_code => "MEC ENG 98",
            :slug => "mec_eng-98",
            :dept => 'MEC ENG',
            :title => "Supervised Independent Group Studies",
            :role => "Instructor",
            :sections => [
              { :ccn => 12345.to_s, :instruction_format => "GRP", :is_primary_section => true, :section_label => "GRP 015", :section_number => "015" }
            ]
          }
        ]
      end
      section_definitions = [{'name' => 'MEC ENG 98 GRP 015', 'course_id' => 'CRS:MEC_ENG-98-2013-D', 'section_id' => 'SEC:2013-D-12345', 'status' => 'active'}]
      allow(subject).to receive(:generate_section_definitions).and_return(section_definitions)
    end

    it "raises exception if course term is not present" do
      subject.instance_eval { @import_data['term'] = nil }
      expect { subject.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. Term data is not present.")
    end

    it "raises exception if SIS course ID is not present" do
      subject.instance_eval { @import_data['sis_course_id'] = nil }
      expect { subject.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. SIS Course ID is not present.")
    end

    it "raises exception if courses list is not present" do
      subject.instance_eval { @import_data['courses'] = nil }
      expect { subject.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. Courses list is not present.")
    end

    it "populates the section definitions" do
      subject.prepare_section_definitions
      section_definitions = subject.instance_eval { @import_data['section_definitions'] }
      expect(section_definitions).to be_an_instance_of Array
      expect(section_definitions[0]["status"]).to eq "active"
      expect(section_definitions[0]["name"]).to eq "MEC ENG 98 GRP 015"
      expect(section_definitions[0]["course_id"]).to eq "CRS:MEC_ENG-98-2013-D"
      expect(section_definitions[0]["section_id"]).to eq "SEC:2013-D-12345"
    end

    it "updates completed steps list" do
      subject.prepare_section_definitions
      expect(subject.instance_eval { @completed_steps }).to eq ["Prepared section definitions"]
    end
  end

  describe "#import_course_site" do
    before do
      @course_row = {"course_id"=>"CRS:COMPSCI-47A-2013-D", "short_name"=>"COMPSCI 47A SLF 001", "long_name"=>"Completion of Work in Computer Science 61A", "account_id"=>"ACCT:COMPSCI", "term_id"=>"TERM:2013-D", "status"=>"active"}
      @canvas_sis_import_proxy_stub = double
      allow(@canvas_sis_import_proxy_stub).to receive(:import_courses).and_return(true)
      allow(subject).to receive(:make_courses_csv).and_return("/csv/filepath")
    end

    it "raises exception if course site import fails" do
      @canvas_sis_import_proxy_stub.stub(:import_courses).and_return(nil)
      allow(Canvas::SisImport).to receive(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { subject.import_course_site(@course_row) }.to raise_error(RuntimeError, "Course site could not be created.")
    end

    it "sets sections csv file path" do
      Canvas::SisImport.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      subject.import_course_site(@course_row)
      filepath = subject.instance_eval { @import_data['courses_csv_file'] }
      expect(filepath).to eq "/csv/filepath"
    end

    it "updates completed steps list" do
      Canvas::SisImport.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      subject.import_course_site(@course_row)
      expect(subject.instance_eval { @completed_steps }).to eq ["Imported course"]
    end
  end

  describe "#import_sections" do
    before do
      @section_rows = [
        {"section_id"=>"SEC:2013-D-26178", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47A SLF 001", "status"=>"active"},
        {"section_id"=>"SEC:2013-D-26181", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47B SLF 001", "status"=>"active"}
      ]
      @canvas_sis_import_proxy_stub = double
      allow(@canvas_sis_import_proxy_stub).to receive(:import_sections).and_return(true)
      allow(subject).to receive(:make_sections_csv).and_return("/csv/filepath")
    end

    it "raises exception if section imports fails" do
      @canvas_sis_import_proxy_stub.stub(:import_sections).and_return(nil)
      allow(Canvas::SisImport).to receive(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { subject.import_sections(@section_rows) }.to raise_error(RuntimeError, "Course site was created without any sections or members! Section import failed.")
    end

    it "sets sections csv file path" do
      Canvas::SisImport.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      subject.import_sections(@section_rows)
      filepath = subject.instance_eval { @import_data['sections_csv_file'] }
      expect(filepath).to eq "/csv/filepath"
    end

    it "updates completed steps list" do
      Canvas::SisImport.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      subject.import_sections(@section_rows)
      expect(subject.instance_eval { @completed_steps }).to eq ["Imported sections"]
    end
  end

  describe '#add_instructor_to_sections' do
    let(:section_ids) {[random_id, random_id]}
    let(:section_definitions) {[{
      'section_id' => section_ids[0]
    }, {
      'section_id' => section_ids[1]
    }]}
    it 'adds teacher enrollments to each new section' do
      expect(Canvas::CourseAddUser).to receive(:add_user_to_course_section).with(uid, 'TeacherEnrollment',
        "sis_section_id:#{section_ids[0]}").ordered.and_return({'type' => 'TeacherEnrollment'})
      expect(Canvas::CourseAddUser).to receive(:add_user_to_course_section).with(uid, 'TeacherEnrollment',
        "sis_section_id:#{section_ids[1]}").ordered.and_return({'type' => 'TeacherEnrollment'})
      subject.add_instructor_to_sections(section_definitions)
    end
  end

  describe "#retrieve_course_site_details" do
    before do
      allow(subject).to receive(:course_site_url).and_return("https://berkeley.instructure.com/courses/1253733")
      subject.instance_eval { @import_data['sis_course_id'] = "CRS:COMPSCI-10-2013-D" }
    end

    it "raises exception if SIS course ID not present" do
      subject.instance_eval { @import_data['sis_course_id'] = nil }
      expect { subject.retrieve_course_site_details }.to raise_error(RuntimeError, "Unable to retrieve course site details. SIS Course ID not present.")
    end

    it "sets course site url" do
      subject.retrieve_course_site_details
      expect(subject.instance_eval { @import_data['course_site_url'] }).to eq "https://berkeley.instructure.com/courses/1253733"
    end

    it "updates completed steps list" do
      subject.retrieve_course_site_details
      expect(subject.instance_eval { @completed_steps }).to eq ["Retrieved new course site details"]
    end
  end

  describe "#expire_instructor_sites_cache" do
    it "clears canvas course site cache for user/instructor" do
      expect(Canvas::MergedUserSites).to receive(:expire).with(subject.uid).and_return(nil)
      subject.expire_instructor_sites_cache
    end

    it "updates completed steps list" do
      subject.expire_instructor_sites_cache
      expect(subject.instance_eval { @completed_steps }).to eq ["Clearing bCourses course site cache"]
    end
  end

  describe '#import_enrollments_in_background' do
    let(:course_id) {random_id}
    let(:section_ids) {[random_id, random_id]}
    let(:section_definitions) {[{
      'section_id' => section_ids[0]
    }, {
      'section_id' => section_ids[1]
    }]}
    let(:maintainer) {double}
    it 'should forward to a background job handler' do
      expect(Canvas::SiteMembershipsMaintainer).to receive(:background).and_return(maintainer)
      expect(maintainer).to receive(:import_memberships).with(course_id, section_ids, anything)
      subject.import_enrollments_in_background(course_id, section_definitions)
    end
  end

  describe "#course_site_url" do
    it "should raise exception if no response from Canvas::SisCourse" do
      allow_any_instance_of(Canvas::SisCourse).to receive(:course).and_return(nil)
      expect do
        subject.course_site_url("CRS:COMPSCI-9A-2013-D")
      end.to raise_error(RuntimeError, "Unexpected error obtaining course site URL for CRS:COMPSCI-9A-2013-D!")
    end

    it "should return course site URL when provided with valid sis id" do
      allow(Settings.canvas_proxy).to receive(:url_root).and_return("https://berkeley.instructure.com")
      allow_any_instance_of(Canvas::SisCourse).to receive(:course).and_return({"id" => 1253733})
      expect(subject.course_site_url("CRS:COMPSCI-9A-2013-D")).to eq "https://berkeley.instructure.com/courses/1253733"
    end
  end

  describe "#current_terms" do
    let(:term_codes) do
      [
        double(year: 2013, code: 'C', slug: 'summer-2013', to_english: 'Summer 2013'),
        double(year: 2013, code: 'D', slug: 'fall-2013', to_english: 'Fall 2013')
      ]
    end
    it "returns array of term hashes" do
      expect(Canvas::Proxy).to receive(:canvas_current_terms).and_return(term_codes)
      result = subject.current_terms
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]).to be_an_instance_of Hash
      expect(result[1]).to be_an_instance_of Hash
      expect(result[0][:yr]).to eq "2013"
      expect(result[1][:yr]).to eq "2013"
      expect(result[0][:cd]).to eq "C"
      expect(result[1][:cd]).to eq "D"
      expect(result[0][:slug]).to eq "summer-2013"
      expect(result[1][:slug]).to eq "fall-2013"
    end
  end

  describe "#candidate_courses_list" do
    it "should raise exception if user id not initialized" do
      subject.instance_eval { @uid = nil }
      expect { subject.candidate_courses_list }.to raise_error(RuntimeError, "User ID not found for candidate")
    end

    it "should get properly formatted candidate course list from fake Oracle MV", :if => CampusOracle::Connection.test_data? do
      terms_feed = Canvas::ProvideCourseSite.new("238382").candidate_courses_list
      expect(terms_feed.length).to eq 1
      expect(terms_feed[0][:name]).to eq "Fall 2013"
      feed = terms_feed[0][:classes]
      expect(feed.length).to eq 2
      bio1a = feed.select {|course| course[:course_code] == 'BIOLOGY 1A'}[0]
      expect(bio1a.empty?).to be_false
      expect(bio1a[:title]).to eq "General Biology Lecture"
      expect(bio1a[:role]).to eq "Instructor"
      expect(bio1a[:sections].length).to eq 3
      expect(bio1a[:sections][0][:is_primary_section]).to be_true
      expect(bio1a[:sections][1][:is_primary_section]).to be_false
      expect(bio1a[:sections][2][:is_primary_section]).to be_false

      cogsci = feed.select {|course| course[:course_code] == 'COG SCI C147'}[0]
      expect(cogsci.empty?).to be_false
      expect(cogsci[:title]).to eq "Language Disorders"
    end
  end

  describe "#filter_courses_by_ccns" do
    before do
      @selected_cnns = [
        rand(99999).to_s,
        rand(99999).to_s
      ]
      @candidate_courses_list = [
        {
          :course_code => "ENGIN 7",
          :slug => "engin-7",
          :dept => 'COMPSCI',
          :title => "Introduction to Computer Programming for Scientists and Engineers",
          :role => "Instructor",
          :sections => [
            { :ccn => rand(99999).to_s, :instruction_format => "LEC", :is_primary_section => true, :section_label => "LEC 002", :section_number => "002" },
            { :ccn => "#{@selected_cnns[1]}", :instruction_format => "DIS", :is_primary_section => false, :section_label => "DIS 102", :section_number => "102" }
          ]
        },
        {
          :course_code => "MEC ENG 98",
          :slug => "mec_eng-98",
          :dept => 'MEC ENG',
          :title => "Supervised Independent Group Studies",
          :role => "Instructor",
          :sections => [
            { :ccn => rand(99999).to_s, :instruction_format => "GRP", :is_primary_section => true, :section_label => "GRP 015", :section_number => "015" }
          ]
        },
        {
          :course_code => "MEC ENG H194",
          :slug => "mec_eng-h194",
          :dept => 'MEC ENG',
          :title => "Honors Undergraduate Research",
          :role => "Instructor",
          :sections => [
            { :ccn => "#{@selected_cnns[0]}", :instruction_format => "IND", :is_primary_section => true, :section_label => "IND 015", :section_number => "015" }
          ]
        },
        {
          :course_code => "MEC ENG 297",
          :slug => "mec_eng-297",
          :dept => 'MEC ENG',
          :title => "Engineering Field Studies",
          :role => "Instructor",
          :sections => [
            { :ccn => rand(99999).to_s, :instruction_format => "IND", :is_primary_section => true, :section_label => "IND 024", :section_number => "024" }
          ]
        }
      ]
      @term_slug = 'fall-2013'
      @candidate_terms_list = [
          {
              name: 'Fall 2013',
              slug: @term_slug,
              classes: @candidate_courses_list
          }
      ]
    end

    # TODO it "should show which sections already have Canvas course sites" do

    it "should raise exception when term slug not found in courses list" do
      expect { subject.filter_courses_by_ccns(@candidate_terms_list, 'summer-2011', @selected_cnns) }.to raise_error(ArgumentError, "No courses found!")
    end

    it "should filter courses data by POSTed CCN selection" do
      filtered = subject.filter_courses_by_ccns(@candidate_terms_list, @term_slug, @selected_cnns)
      expect(filtered.length).to eq 2
      expect(filtered[0][:course_code]).to eq 'ENGIN 7'
      expect(filtered[0][:dept]).to eq 'COMPSCI'
      expect(filtered[0][:sections].length).to eq 1
      expect(filtered[0][:sections][0][:section_label]).to eq "DIS 102"
      expect(filtered[1][:course_code]).to eq 'MEC ENG H194'
      expect(filtered[1][:dept]).to eq 'MEC ENG'
      expect(filtered[1][:sections].length).to eq 1
      expect(filtered[1][:sections][0][:section_label]).to eq "IND 015"
    end
  end

  describe "#generate_course_site_definition" do
    let(:term_yr)     { '2013' }
    let(:term_cd)     { 'D' }
    let(:subaccount)  { 'ACCT:ENGIN' }
    let(:campus_course_slug) { 'engin-7' }

    it "should raise exception when sis course id fails to generate" do
      subject.stub(:generate_unique_sis_course_id).and_return(nil)
      expect do
        subject.generate_course_site_definition(site_name, site_course_code, term_yr, term_cd, subaccount, campus_course_slug)
      end.to raise_error(RuntimeError, "Could not define new course site!")
    end

    it "should generate a Course import CSV row for the selected courses" do
      allow_any_instance_of(Canvas::ExistenceCheck).to receive(:course_defined?).and_return(false)
      canvas_course = subject.generate_course_site_definition(site_name, site_course_code, term_yr, term_cd, subaccount, campus_course_slug)
      expect(canvas_course['course_id'].present?).to be_true
      expect(canvas_course['course_id']).to eq "CRS:ENGIN-7-2013-D"
      expect(canvas_course['short_name']).to eq 'ENGIN 7'
      expect(canvas_course['long_name']).to eq 'Introduction to Computer Programming for Scientists and Engineers'
      expect(canvas_course['account_id']).to eq 'ACCT:ENGIN'
      expect(canvas_course['term_id']).to eq 'TERM:2013-D'
      expect(canvas_course['status']).to eq 'active'
    end

    it "should generate a unique Course SIS ID for the selected courses" do
      # RSpec does not currently redefine any_instance class stubs: http://stackoverflow.com/questions/18092601/rspec-any-instance-stub-does-not-restub-old-instances
      stub_existence_check = double
      expect(stub_existence_check).to receive(:course_defined?).and_return(false)
      allow(Canvas::ExistenceCheck).to receive(:new).and_return(stub_existence_check)

      first_canvas_course = subject.generate_course_site_definition(site_name, site_course_code, term_yr, term_cd, subaccount, campus_course_slug)
      first_course_sis_id = first_canvas_course['course_id']
      expect(stub_existence_check).to receive(:course_defined?).twice do |id|
        id == first_course_sis_id
      end
      second_canvas_course = subject.generate_course_site_definition(site_name, site_course_code, term_yr, term_cd, subaccount, campus_course_slug)
      second_course_sis_id = second_canvas_course['course_id']
      expect(second_course_sis_id.present?).to be_true
      expect(second_course_sis_id).to_not eq first_course_sis_id
    end
  end

  describe "#generate_unique_sis_course_id" do
    it "should generate a standard sis course id when a canvas course does not already exist" do
      stub_existence_proxy = double
      allow(stub_existence_proxy).to receive(:course_defined?).and_return(false)
      result = subject.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      result.should == "CRS:ETH_STD-C73ABC-2015-F"
    end

    it "should return a unique course id when a canvas course already exists" do
      # emulate course defined already twice
      stub_existence_proxy = double
      allow(stub_existence_proxy).to receive(:course_defined?).and_return(true, true, false)
      allow(SecureRandom).to receive(:hex).and_return("e2383290", "697c834e")
      result = subject.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      expect(result).to eq "CRS:ETH_STD-C73ABC-2015-F-697C834E"
    end

    it "should raise exception if unique course id not generated after 20 attempts" do
      stub_existence_proxy = double
      course_defined_responses = (1..21).to_a.map {|e| true} # array of 20 true responses
      allow(stub_existence_proxy).to receive(:course_defined?).and_return(course_defined_responses)
      expect do
        subject.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      end.to raise_error(Canvas::ProvideCourseSite::IdNotUniqueException)
    end
  end

  describe "#generate_section_definitions" do
    it "should raise exception if campus_section_data argument is empty" do
      expect do
        subject.generate_section_definitions('2013', 'D', 'CRS:ENGIN-7-2013-D', [])
      end.to raise_error(ArgumentError, "'campus_section_data' argument is empty")
    end

    it "should generate Canvas Section import CSV rows for the selected courses" do
      term_yr = '2013'
      term_cd = 'D'
      ccns = [
          rand(99999).to_s,
          rand(99999).to_s,
          rand(99999).to_s
      ]
      courses_list = [
          {:course_code => "ENGIN 7",
           :slug => "engin-7",
           :title =>
               "Introduction to Computer Programming for Scientists and Engineers",
           :role => "Instructor",
           :sections =>
               [{:ccn => ccns[0],
                 :instruction_format => "LEC",
                 :is_primary_section => true,
                 :section_label => "LEC 002",
                 :section_number => "002"},
                {:ccn => ccns[1],
                 :instruction_format => "DIS",
                 :is_primary_section => false,
                 :section_label => "DIS 102",
                 :section_number => "102"}]},
          {:course_code => "MEC ENG 98",
           :slug => "mec_eng-98",
           :title => "Supervised Independent Group Studies",
           :role => "Instructor",
           :sections =>
               [{:ccn => ccns[2],
                 :instruction_format => "GRP",
                 :is_primary_section => true,
                 :section_label => "GRP 015",
                 :section_number => "015"}]}
      ]
      sis_course_id = 'CRS:ENGIN-7-2013-D-8383'
      allow_any_instance_of(Canvas::ExistenceCheck).to receive(:section_defined?).and_return(false)
      canvas_sections_list = subject.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)
      expect(canvas_sections_list.length).to eq 3
      canvas_sections_list.each do |row|
        expect(row['course_id']).to eq sis_course_id
        expect(row['status']).to eq 'active'
        campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(row['section_id'])
        expect(campus_section[:term_yr]).to eq term_yr
        expect(campus_section[:term_cd]).to eq term_cd
        expect(ccns.include?(campus_section[:ccn])).to be_true
      end
      expect(canvas_sections_list[0]['name']).to eq 'ENGIN 7 LEC 002'
      expect(canvas_sections_list[1]['name']).to eq 'ENGIN 7 DIS 102'
      expect(canvas_sections_list[2]['name']).to eq 'MEC ENG 98 GRP 015'
    end

    it "should generate a unique parsable Section SIS ID for the selected sections" do
      term_yr = '2013'
      term_cd = 'D'
      ccn = rand(99999).to_s
      courses_list = [
          {:course_code => "ENGIN 7",
           :dept => "ENGIN",
           :slug => "engin-7",
           :title =>
               "Introduction to Computer Programming for Scientists and Engineers",
           :role => "Instructor",
           :sections =>
               [{:ccn => ccn,
                 :instruction_format => "DIS",
                 :is_primary_section => false,
                 :section_label => "DIS 102",
                 :section_number => "102"}]}
      ]
      sis_course_id = 'CRS:ENGIN-7-2013-D-8383'

      # RSpec does not currently redefine any_instance class stubs: http://stackoverflow.com/questions/18092601/rspec-any-instance-stub-does-not-restub-old-instances
      stub_existence_check = double
      expect(stub_existence_check).to receive(:section_defined?).and_return(false)
      allow(Canvas::ExistenceCheck).to receive(:new).and_return(stub_existence_check)

      first_canvas_section = subject.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)[0]
      first_canvas_section_id = first_canvas_section['section_id']

      expect(stub_existence_check).to receive(:section_defined?).twice do |id|
        id == first_canvas_section_id
      end

      second_canvas_section = subject.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)[0]
      second_canvas_section_id = second_canvas_section['section_id']
      expect(second_canvas_section_id.present?).to be_true
      expect(second_canvas_section_id).to_not eq first_canvas_section_id
      campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(second_canvas_section_id)
      expect(campus_section[:term_yr]).to eq term_yr
      expect(campus_section[:term_cd]).to eq term_cd
      expect(campus_section[:ccn]).to eq ccn
    end
  end

  describe "#subaccount_for_department" do
    it "should return the subaccount if it exists in Canvas" do
      allow_any_instance_of(Canvas::ExistenceCheck).to receive(:account_defined?).and_return(true)
      result = subject.subaccount_for_department('COMPSCI')
      expect(result).to eq "ACCT:COMPSCI"
    end

    it "should replace forwards slashes with underscores in the subaccount name" do
      allow_any_instance_of(Canvas::ExistenceCheck).to receive(:account_defined?).and_return(true)
      result = subject.subaccount_for_department('MALAY/I')
      expect(result).to eq "ACCT:MALAY_I"
    end

    it "should raise exception if the subaccount does not exist in Canvas" do
      allow_any_instance_of(Canvas::ExistenceCheck).to receive(:account_defined?).and_return(false)
      expect { subject.subaccount_for_department('COMPSCI') }.to raise_error(RuntimeError, 'Could not find bCourses account for department COMPSCI')
    end
  end

  describe "#find_term" do
    before(:each) do
      term_codes_array = [
        {yr: '3026', cd: 'C', slug: "summer-3026"},
        {yr: '3026', cd: 'D', slug: "fall-3026"},
      ]
      subject.stub(:current_terms).and_return(term_codes_array)
    end

    it "should return term code hash when slug matches a current term code" do
      result = subject.find_term('fall-3026')
      expect(result).to be_an_instance_of Hash
      expect(result[:yr]).to eq "3026"
      expect(result[:cd]).to eq "D"
      expect(result[:slug]).to eq "fall-3026"
    end

    it "should raise exception when slug does not match a current term code" do
      expect { subject.find_term('winter-3011') }.to raise_error(ArgumentError, "term_slug does not match current term code")
    end
  end

  describe "#courses_list_from_ccns" do
    # Lock down to a known set of sections, either in the test DB or in real campus data.
    let(:term_codes_array) {
      CampusOracle::Connection.test_data? ?
          [{yr: '2013', cd: 'D', slug: "fall-2013"}] :
          [{yr: '2013', cd: 'B', slug: "spring-2013"}]
    }
    before { subject.stub(:current_terms).and_return(term_codes_array)}
    it "formats section information for known CCNs" do
      good_ccns = [7309, 7366, 16171]
      bad_ccns = [919191]
      semesters_list = subject.courses_list_from_ccns(term_codes_array[0][:slug], (good_ccns + bad_ccns))
      expect(semesters_list.length).to eq 1
      classes_list = semesters_list[0][:classes]
      expect(classes_list.length).to eq 2
      bio_class = classes_list[0]
      expect(bio_class[:course_code]).to eq 'BIOLOGY 1A'
      sections = bio_class[:sections]
      expect(sections.length).to eq 2
      expect(sections[0][:ccn].to_i).to eq 7309
      expect(sections[0][:section_label]).to eq 'LEC 003'
      expect(sections[0][:is_primary_section]).to be_true
      expect(sections[1][:ccn].to_i).to eq 7366
      expect(sections[1][:is_primary_section]).to be_false
      cog_sci_class = classes_list[1]
      sections = cog_sci_class[:sections]
      expect(sections.length).to eq 1
      expect(sections[0][:ccn].to_i).to eq 16171
    end
  end

  describe "#save" do
    it "raises exception if cache expiration not present" do
      allow(Settings.cache.expiration).to receive(:CanvasCourseProvisioningJobs).and_return(nil)
      expect { subject.save }.to raise_error(RuntimeError, "Unable to save. Cache expiration setting not present.")
    end

    it "raises exception if cache key not present" do
      subject.instance_eval { @cache_key = nil }
      expect { subject.save }.to raise_error(RuntimeError, "Unable to save. cache_key missing")
    end

    it "saves current state of job to global storage" do
      allow(Canvas::ProvideCourseSite).to receive(:unique_job_id).and_return('1383330151057')
      subject.save
      retrieved_job = Canvas::ProvideCourseSite.find(subject.job_id)
      expect(retrieved_job).to be_an_instance_of Canvas::ProvideCourseSite
      expect(retrieved_job.uid).to eq uid
      expect(retrieved_job.status).to eq 'New'
      expect(retrieved_job.job_id).to eq "canvas.courseprovision.#{uid}.1383330151057"
    end
  end

  describe "#complete_step" do
    it "adds step to completed steps log" do
      subject.complete_step("Did something awesome")
      subject.instance_eval { @completed_steps }.should == ["Did something awesome"]
    end

    it "saves state of background job" do
      expect(subject).to receive(:save).and_return(true)
      subject.complete_step("Did something awesome")
    end
  end

  describe "#to_json" do
    before do
      subject.instance_eval { @status = 'Error'}
      subject.instance_eval { @cache_key = 'canvas.courseprovision.1234.1383330151057'}
      subject.instance_eval { @completed_steps = ['step1 description', 'step2 description']}
    end

    it "returns hash containing course import job state" do
      result = subject.to_json
      result.should be_an_instance_of String
      json_result = JSON.parse(result)
      expect(json_result['status']).to eq 'Error'
      expect(json_result['job_id']).to eq 'canvas.courseprovision.1234.1383330151057'
      expect(json_result['completed_steps'][0]).to eq 'step1 description'
      expect(json_result['completed_steps'][1]).to eq 'step2 description'
      expect(json_result['percent_complete']).to eq 0.17
      expect(json_result['course_site']).to_not be
      expect(json_result['error']).to_not be
    end

    context "when job status is completed" do
      it "includes course site details" do
        subject.instance_eval do
          @status = 'Completed'
          @import_data['course_site_url'] = "https://example.com/courses/999"
          @import_data['course_site_short_name'] = "COMPSCI-10"
        end
        json_result = JSON.parse(subject.to_json)
        expect(json_result['course_site']).to be_an_instance_of Hash
        expect(json_result['course_site']['short_name']).to eq "COMPSCI-10"
        expect(json_result['course_site']['url']).to eq "https://example.com/courses/999"
        expect(json_result['error']).to_not be
      end
    end

    context "when job status is error" do
      it "includes error messages string" do
        subject.instance_eval do
          @status = 'Error'
          @errors << "Error Message 1"
          @errors << "Error Message 2"
        end
        json_result = JSON.parse(subject.to_json)
        expect(json_result['error']).to eq "Error Message 1; Error Message 2"
        expect(json_result['course_site']).to_not be
      end
    end
  end

  describe "#job_id" do
    it "returns cache key" do
      job_id = subject.instance_eval { @cache_key }
      expect(subject.job_id).to eq job_id
    end
  end

end
