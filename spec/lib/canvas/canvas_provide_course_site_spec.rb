require "spec_helper"

describe CanvasProvideCourseSite do

  let(:uid)                           { rand(99999).to_s }
  let(:canvas_provide_course_site)    { CanvasProvideCourseSite.new(uid) }
  let(:worker)                        { canvas_provide_course_site }

  #####################################
  # Class Methods

  describe ".unique_job_id" do
    it "returns unique job id based on current time" do
      current_time = Time.at(1383330151.057)
      Time.should_receive(:now).and_return(current_time)
      result = CanvasProvideCourseSite.unique_job_id
      result.should == "1383330151057"
    end
  end

  describe ".find" do
    it "returns the current job object from global storage" do
      job_state = { status: 'Completed' }
      Rails.cache.write('canvas.courseprovision.1234.123456789', job_state, expires_in: 5.seconds.to_i, raw: true)
      result = CanvasProvideCourseSite.find('canvas.courseprovision.1234.123456789')
      result.should == job_state
    end

    it "returns nil if job state not found" do
      result = CanvasProvideCourseSite.find('canvas.courseprovision.1234.123456789')
      result.should be_nil
    end
  end

  #####################################
  # Instance Methods

  describe "#initialize" do
    it "raises exception if uid is not a String" do
      expect { CanvasProvideCourseSite.new(1234) }.to raise_error(ArgumentError, "uid must be a String")
    end

    it "has the users id" do
      expect(canvas_provide_course_site.uid).to eq uid
    end

    it "defaults to status 'new'" do
      expect(canvas_provide_course_site.status).to eq 'New'
    end

    it "initializes the completed steps array" do
      expect(canvas_provide_course_site.instance_eval { @completed_steps }).to eq []
    end

    it "initializes the error array" do
      expect(canvas_provide_course_site.instance_eval { @errors }).to eq []
    end

    it "initializes the import data hash" do
      expect(canvas_provide_course_site.instance_eval { @import_data }).to be_an_instance_of Hash
      expect(canvas_provide_course_site.instance_eval { @import_data }).to eq({})
    end

    it "initializes with unique cache key" do
      CanvasProvideCourseSite.stub(:unique_job_id).and_return('1383330151057')
      expect(canvas_provide_course_site.cache_key).to eq "canvas.courseprovision.#{uid}.1383330151057"
    end
  end

  describe "#create_course_site" do
    before do
      canvas_provide_course_site.stub(:prepare_users_courses_list).and_return(true)
      canvas_provide_course_site.stub(:identify_department_subaccount).and_return(true)
      canvas_provide_course_site.stub(:prepare_course_site_definition).and_return(true)
      canvas_provide_course_site.stub(:prepare_section_definitions).and_return(true)
      canvas_provide_course_site.stub(:prepare_user_definitions).and_return(true)
      canvas_provide_course_site.stub(:prepare_course_site_memberships).and_return(true)
      canvas_provide_course_site.stub(:import_course_site).and_return(true)
      canvas_provide_course_site.stub(:import_sections).and_return(true)
      canvas_provide_course_site.stub(:import_users).and_return(true)
      canvas_provide_course_site.stub(:import_enrollments).and_return(true)
      canvas_provide_course_site.stub(:retrieve_course_site_details).and_return(true)
      canvas_provide_course_site.stub(:expire_instructor_sites_cache).and_return(true)
    end

    it "intercepts raised exceptions and updates status" do
      canvas_provide_course_site.stub(:import_course_site).and_raise(RuntimeError, "Course site could not be created!")
      expect { canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"]) }.to raise_error(RuntimeError, "Course site could not be created!")
      canvas_provide_course_site.status.should == "Error"
      errors = canvas_provide_course_site.instance_eval { @errors }
      errors.should be_an_instance_of Array
      errors[0].should == "Course site could not be created!"
    end

    it "makes calls to each step of import in proper order" do
      canvas_provide_course_site.should_receive(:prepare_users_courses_list).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:identify_department_subaccount).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:prepare_course_site_definition).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:prepare_section_definitions).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:prepare_user_definitions).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:prepare_course_site_memberships).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:import_course_site).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:import_sections).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:import_users).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:import_enrollments).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:retrieve_course_site_details).ordered.and_return(true)
      canvas_provide_course_site.should_receive(:expire_instructor_sites_cache).ordered.and_return(true)
      canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"])
    end

    it "sets term and ccns for import" do
      canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"])
      canvas_provide_course_site.instance_eval { @import_data['term_slug'] }.should == "fall-2013"
      canvas_provide_course_site.instance_eval { @import_data['term'][:yr] }.should == "2013"
      canvas_provide_course_site.instance_eval { @import_data['term'][:cd] }.should == "D"
      canvas_provide_course_site.instance_eval { @import_data['ccns'] }.should == ["1136", "1204"]
    end

    it "sets status as completed and saves" do
      canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"])
      cached_object = CanvasProvideCourseSite.find(canvas_provide_course_site.job_id)
      cached_object.status.should == "Completed"
    end
  end

  describe "#prepare_users_courses_list" do
    before do
      canvas_provide_course_site.instance_eval do
        @import_data['term_slug'] = "fall-2013"
        @import_data['ccns'] = ["1136", "1204"]
      end
      @filtered_courses_list = [
        {
          :course_number=>"COMPSCI 10",
          :dept=>"COMPSCI",
          :slug=>"compsci-10",
          :title=>"The Beauty and Joy of Computing",
          :role=>"Instructor",
          :sections=>[
            {:ccn=>"1136", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:building_name=>"SODA", :room_number=>"0320", :schedule=>"M 8:00A-9:00A"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]},
            {:ccn=>"1204", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 109", :section_number=>"109", :schedules=>[{:building_name=>"SODA", :room_number=>"0320", :schedule=>"M 12:00P-1:00P"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]}
          ]
        }
      ]
    end

    it "raises exception if term slug not present in import data set" do
      canvas_provide_course_site.instance_eval { @import_data['term_slug'] = nil }
      expect { canvas_provide_course_site.prepare_users_courses_list }.to raise_error(RuntimeError, "Unable to prepare course list. Term slug not present.")
    end

    it "raises exception if course control numbers are not present in import data set" do
      canvas_provide_course_site.instance_eval { @import_data['ccns'] = nil }
      expect { canvas_provide_course_site.prepare_users_courses_list }.to raise_error(RuntimeError, "Unable to prepare course list. CCNs not present.")
    end

    it "assigns user courses set to import data hash" do
      canvas_provide_course_site.stub(:candidate_courses_list).and_return(true)
      canvas_provide_course_site.should_receive(:filter_courses_by_ccns).and_return(@filtered_courses_list)
      canvas_provide_course_site.prepare_users_courses_list
      assigned_courses = canvas_provide_course_site.instance_eval { @import_data['courses'] }
      assigned_courses.should be_an_instance_of Array
      assigned_courses.count.should == 1
      assigned_courses[0].should be_an_instance_of Hash
      assigned_courses[0][:course_number].should == "COMPSCI 10"
    end

    it "lets admins specify CCNs directly" do
      canvas_provide_course_site.instance_eval { @import_data['is_admin_by_ccns'] = true }
      canvas_provide_course_site.should_not_receive(:candidate_courses_list)
      canvas_provide_course_site.should_not_receive(:filter_courses_by_ccns)
      canvas_provide_course_site.should_receive(:courses_list_from_ccns).and_return(@filtered_courses_list)
      canvas_provide_course_site.prepare_users_courses_list
    end

    it "updates completed steps list" do
      canvas_provide_course_site.stub(:candidate_courses_list).and_return(true)
      canvas_provide_course_site.should_receive(:filter_courses_by_ccns).and_return("user_courses_list")
      canvas_provide_course_site.prepare_users_courses_list
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Prepared courses list"]
    end
  end

  describe "#identify_department_subaccount" do
    before do
      canvas_provide_course_site.stub(:subaccount_for_department).and_return('ACCT:COMPSCI')
      canvas_provide_course_site.instance_eval { @import_data['courses'] = [{:course_number => 'ENGIN 7', :dept => 'COMPSCI', :sections => []}] }
    end

    it "raises exception if import courses not present" do
      canvas_provide_course_site.instance_eval { @import_data['courses'] = nil }
      expect { canvas_provide_course_site.identify_department_subaccount }.to raise_error(RuntimeError, "Unable identify department subaccount. Course list not loaded or empty.")
    end

    it "adds department id to import data" do
      canvas_provide_course_site.identify_department_subaccount
      canvas_provide_course_site.instance_eval { @import_data['subaccount'] }.should == 'ACCT:COMPSCI'
    end

    it "updates completed steps list" do
      canvas_provide_course_site.identify_department_subaccount
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Identified department sub-account"]
    end
  end

  describe "#prepare_course_site_definition" do
    before do
      canvas_provide_course_site.instance_eval do
        @import_data['term'] = {yr: '2013', cd: 'D', slug: "fall-2013"}
        @import_data['subaccount'] = "ACCT:COMPSCI"
        @import_data['courses'] = [
          {
            :course_number => "MEC ENG 98",
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
      canvas_provide_course_site.stub(:generate_course_site_definition).and_return(course_site_definition)
    end

    it "raises exception if course term is not present" do
      canvas_provide_course_site.instance_eval { @import_data['term'] = nil }
      expect { canvas_provide_course_site.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Term data is not present.")
    end

    it "raises exception if department subaccount is not present" do
      canvas_provide_course_site.instance_eval { @import_data['subaccount'] = nil }
      expect { canvas_provide_course_site.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Department subaccount ID not present.")
    end

    it "raises exception if courses list is not present" do
      canvas_provide_course_site.instance_eval { @import_data['courses'] = nil }
      expect { canvas_provide_course_site.prepare_course_site_definition }.to raise_error(RuntimeError, "Unable to prepare course site definition. Courses list is not present.")
    end

    it "populates the course site definition" do
      canvas_provide_course_site.prepare_course_site_definition
      course_site_definition = canvas_provide_course_site.instance_eval { @import_data['course_site_definition'] }
      course_site_definition.should be_an_instance_of Hash
      course_site_definition['status'].should == "active"
      course_site_definition['course_id'].should == "CRS:MEC_ENG-98-2013-D"
      course_site_definition['account_id'].should == "ACCT:COMPSCI"
      course_site_definition['term_id'].should == "TERM:2013-D"
      course_site_definition['short_name'].should == "MEC ENG 98 GRP 015"
      course_site_definition['long_name'].should == "Supervised Independent Group Studies"
    end

    it "sets the sis course id" do
      canvas_provide_course_site.prepare_course_site_definition
      sis_course_id = canvas_provide_course_site.instance_eval { @import_data['sis_course_id'] }
      sis_course_id.should == "CRS:MEC_ENG-98-2013-D"
    end

    it "sets the course site short name" do
      canvas_provide_course_site.prepare_course_site_definition
      course_site_short_name = canvas_provide_course_site.instance_eval { @import_data['course_site_short_name'] }
      course_site_short_name.should == "MEC ENG 98 GRP 015"
    end

    it "updates completed steps list" do
      canvas_provide_course_site.prepare_course_site_definition
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Prepared course site definition"]
    end
  end

  describe "#prepare_section_definitions" do
    before do
      canvas_provide_course_site.instance_eval do
        @import_data['term'] = {yr: '2013', cd: 'D', slug: "fall-2013"}
        @import_data['sis_course_id'] = "CRS:MEC_ENG-98-2013-D"
        @import_data['courses'] = [
          {
            :course_number => "MEC ENG 98",
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
      canvas_provide_course_site.stub(:generate_section_definitions).and_return(section_definitions)
    end

    it "raises exception if course term is not present" do
      canvas_provide_course_site.instance_eval { @import_data['term'] = nil }
      expect { canvas_provide_course_site.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. Term data is not present.")
    end

    it "raises exception if SIS course ID is not present" do
      canvas_provide_course_site.instance_eval { @import_data['sis_course_id'] = nil }
      expect { canvas_provide_course_site.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. SIS Course ID is not present.")
    end

    it "raises exception if courses list is not present" do
      canvas_provide_course_site.instance_eval { @import_data['courses'] = nil }
      expect { canvas_provide_course_site.prepare_section_definitions }.to raise_error(RuntimeError, "Unable to prepare section definitions. Courses list is not present.")
    end

    it "populates the section definitions" do
      canvas_provide_course_site.prepare_section_definitions
      section_definitions = canvas_provide_course_site.instance_eval { @import_data['section_definitions'] }
      section_definitions.should be_an_instance_of Array
      section_definitions[0]["status"].should == "active"
      section_definitions[0]["name"].should == "MEC ENG 98 GRP 015"
      section_definitions[0]["course_id"].should == "CRS:MEC_ENG-98-2013-D"
      section_definitions[0]["section_id"].should == "SEC:2013-D-12345"
    end

    it "updates completed steps list" do
      canvas_provide_course_site.prepare_section_definitions
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Prepared section definitions"]
    end
  end

  describe "#prepare_user_definitions" do
    it "raises exception if user id is not present" do
      canvas_provide_course_site.instance_eval { @uid = nil }
      expect { canvas_provide_course_site.prepare_user_definitions }.to raise_error(RuntimeError, "Unable to prepare user definition. User ID is not present.")
    end

    it "populates the user definitions" do
      user_definitions = [
        {
          "user_id" => "UID:1234",
          "login_id" => "1234",
          "first_name" => "John",
          "last_name" => "Smith",
          "email" => "jsmith@example.com",
          "status" => "active",
        }
      ]
      canvas_provide_course_site.stub(:accumulate_user_data).and_return(user_definitions)
      canvas_provide_course_site.prepare_user_definitions
      section_definitions = canvas_provide_course_site.instance_eval { @import_data['user_definitions'] }
      section_definitions.should be_an_instance_of Array
      section_definitions[0].should be_an_instance_of Hash
      section_definitions[0]['login_id'].should == "1234"
    end

    it "updates completed steps list" do
      canvas_provide_course_site.prepare_user_definitions
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Prepared user definitions"]
    end
  end

  describe "#prepare_course_site_memberships" do
    before do
      canvas_provide_course_site.instance_eval do
        @import_data['section_definitions'] = [
          {
            "status" => "active",
            "name" => "MEC ENG 98 GRP 015",
            "course_id" => "CRS:MEC_ENG-98-2013-D",
            "section_id" => "SEC:2013-D-12345",
          }
        ]
        @import_data['user_definitions'] = [
          {
            "user_id" => "UID:1234",
            "login_id" => "1234",
            "first_name" => "John",
            "last_name" => "Smith",
            "email" => "jsmith@example.com",
            "status" => "active",
          }
        ]
      end
    end

    it "raises exception if section definitions are not present" do
      canvas_provide_course_site.instance_eval { @import_data['section_definitions'] = nil }
      expect { canvas_provide_course_site.prepare_course_site_memberships }.to raise_error(RuntimeError, "Unable to prepare course site memberships. Section definitions are not present.")
    end

    it "raises exception if user definitions are not present" do
      canvas_provide_course_site.instance_eval { @import_data['user_definitions'] = nil }
      expect { canvas_provide_course_site.prepare_course_site_memberships }.to raise_error(RuntimeError, "Unable to prepare course site memberships. User definitions are not present.")
    end

    it "populates the course membership definitions" do
      canvas_provide_course_site.prepare_course_site_memberships
      course_memberships = canvas_provide_course_site.instance_eval { @import_data['course_memberships'] }
      course_memberships.should be_an_instance_of Array
      course_memberships[0].should be_an_instance_of Hash
      course_memberships[0]["status"].should == "active"
      course_memberships[0]["role"].should == "teacher"
      course_memberships[0]["user_id"].should == "UID:1234"
      course_memberships[0]["course_id"].should == "CRS:MEC_ENG-98-2013-D"
      course_memberships[0]["section_id"].should == "SEC:2013-D-12345"
    end

    it "updates completed steps list" do
      canvas_provide_course_site.prepare_course_site_memberships
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Prepared course site memberships"]
    end
  end

  describe "#import_course_site" do
    before do
      @course_row = {"course_id"=>"CRS:COMPSCI-47A-2013-D", "short_name"=>"COMPSCI 47A SLF 001", "long_name"=>"Completion of Work in Computer Science 61A", "account_id"=>"ACCT:COMPSCI", "term_id"=>"TERM:2013-D", "status"=>"active"}
      @canvas_sis_import_proxy_stub = double
      @canvas_sis_import_proxy_stub.stub(:import_courses).and_return(true)
      canvas_provide_course_site.stub(:make_courses_csv).and_return("/csv/filepath")
    end

    it "raises exception if course site import fails" do
      @canvas_sis_import_proxy_stub.stub(:import_courses).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { canvas_provide_course_site.import_course_site(@course_row) }.to raise_error(RuntimeError, "Course site could not be created.")
    end

    it "sets sections csv file path" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_course_site(@course_row)
      filepath = canvas_provide_course_site.instance_eval { @import_data['courses_csv_file'] }
      filepath.should == "/csv/filepath"
    end

    it "updates completed steps list" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_course_site(@course_row)
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Imported course"]
    end
  end

  describe "#import_sections" do
    before do
      @section_rows = [
        {"section_id"=>"SEC:2013-D-26178", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47A SLF 001", "status"=>"active"},
        {"section_id"=>"SEC:2013-D-26181", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47B SLF 001", "status"=>"active"}
      ]
      @canvas_sis_import_proxy_stub = double
      @canvas_sis_import_proxy_stub.stub(:import_sections).and_return(true)
      canvas_provide_course_site.stub(:make_sections_csv).and_return("/csv/filepath")
    end

    it "raises exception if section imports fails" do
      @canvas_sis_import_proxy_stub.stub(:import_sections).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { canvas_provide_course_site.import_sections(@section_rows) }.to raise_error(RuntimeError, "Course site was created without any sections or members! Section import failed.")
    end

    it "sets sections csv file path" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_sections(@section_rows)
      filepath = canvas_provide_course_site.instance_eval { @import_data['sections_csv_file'] }
      filepath.should == "/csv/filepath"
    end

    it "updates completed steps list" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_sections(@section_rows)
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Imported sections"]
    end
  end

  describe "#import_users" do
    before do
      @user_rows = [{"user_id"=>"UID:1234", "login_id"=>"1234", "first_name"=>"John", "last_name"=>"Smith", "email"=>"johnsmith@berkeley.edu", "status"=>"active"}]
      @canvas_sis_import_proxy_stub = double
      @canvas_sis_import_proxy_stub.stub(:import_users).and_return(true)
      canvas_provide_course_site.stub(:make_users_csv).and_return("/csv/filepath")
    end

    it "raises exception if user imports fails" do
      @canvas_sis_import_proxy_stub.stub(:import_users).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { canvas_provide_course_site.import_users(@user_rows) }.to raise_error(RuntimeError, "Course site was created but members may be missing! User import failed.")
    end

    it "sets sections csv file path" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_users(@user_rows)
      filepath = canvas_provide_course_site.instance_eval { @import_data['users_csv_file'] }
      filepath.should == "/csv/filepath"
    end

    it "updates completed steps list" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_users(@user_rows)
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Imported users"]
    end
  end

  describe "#import_enrollments" do
    before do
      @enrollment_rows = [
        {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26178", "status"=>"active"},
        {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26181", "status"=>"active"}
      ]
      @canvas_sis_import_proxy_stub = double
      @canvas_sis_import_proxy_stub.stub(:import_enrollments).and_return(true)
      canvas_provide_course_site.stub(:make_enrollments_csv).and_return("/csv/filepath")
    end

    it "raises exception if enrollment imports fails" do
      @canvas_sis_import_proxy_stub.stub(:import_enrollments).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      expect { canvas_provide_course_site.import_enrollments(@enrollment_rows) }.to raise_error(RuntimeError, "Course site was created but members may not be enrolled! Enrollment import failed.")
    end

    it "sets sections csv file path" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_enrollments(@enrollment_rows)
      filepath = canvas_provide_course_site.instance_eval { @import_data['enrollments_csv_file'] }
      filepath.should == "/csv/filepath"
    end

    it "updates completed steps list" do
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      canvas_provide_course_site.import_enrollments(@enrollment_rows)
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Imported instructor enrollment"]
    end
  end

  describe "#retrieve_course_site_details" do
    before do
      canvas_provide_course_site.stub(:course_site_url).and_return("https://berkeley.instructure.com/courses/1253733")
      canvas_provide_course_site.instance_eval { @import_data['sis_course_id'] = "CRS:COMPSCI-10-2013-D" }
    end

    it "raises exception if SIS course ID not present" do
      canvas_provide_course_site.instance_eval { @import_data['sis_course_id'] = nil }
      expect { canvas_provide_course_site.retrieve_course_site_details }.to raise_error(RuntimeError, "Unable to retrieve course site details. SIS Course ID not present.")
    end

    it "sets course site url" do
      canvas_provide_course_site.retrieve_course_site_details
      canvas_provide_course_site.instance_eval { @import_data['course_site_url'] }.should == "https://berkeley.instructure.com/courses/1253733"
    end

    it "updates completed steps list" do
      canvas_provide_course_site.retrieve_course_site_details
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Retrieved new course site details"]
    end
  end

  describe "#expire_instructor_sites_cache" do
    it "clears canvas course site cache for user/instructor" do
      CanvasUserSites.should_receive(:expire).with(canvas_provide_course_site.uid).and_return(nil)
      canvas_provide_course_site.expire_instructor_sites_cache
    end

    it "updates completed steps list" do
      canvas_provide_course_site.expire_instructor_sites_cache
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Clearing bCourses course site cache"]
    end
  end

  describe "#course_site_url" do
    it "should raise exception if no response from CanvasCourseProxy" do
      CanvasCourseProxy.any_instance.stub(:course).and_return(nil)
      expect do
        canvas_provide_course_site.course_site_url("CRS:COMPSCI-9A-2013-D")
      end.to raise_error(RuntimeError, "Unexpected error obtaining course site URL for CRS:COMPSCI-9A-2013-D!")
    end

    it "should return course site URL when provided with valid sis id" do
      Settings.canvas_proxy.stub(:url_root).and_return("https://berkeley.instructure.com")
      course_response = double
      course_response.stub(:body).and_return("{\"id\": 1253733}")
      CanvasCourseProxy.any_instance.stub(:course).and_return(course_response)
      result = canvas_provide_course_site.course_site_url("CRS:COMPSCI-9A-2013-D")
      result.should == "https://berkeley.instructure.com/courses/1253733"
    end
  end

  describe "#current_terms" do
    it "returns array of term hashes" do
      term_codes = [OpenStruct.new(term_yr: "2013", term_cd: "C"), OpenStruct.new(term_yr: "2013", term_cd: "D")]
      Settings.canvas_proxy.should_receive(:current_terms_codes).and_return(term_codes)
      result = canvas_provide_course_site.current_terms
      result.should be_an_instance_of Array
      result.count.should == 2
      result[0].should be_an_instance_of Hash
      result[1].should be_an_instance_of Hash
      result[0][:yr].should == "2013"
      result[1][:yr].should == "2013"
      result[0][:cd].should == "C"
      result[1][:cd].should == "D"
      result[0][:slug].should == "summer-2013"
      result[1][:slug].should == "fall-2013"
    end
  end

  describe "#candidate_courses_list" do
    it "should raise exception if user id not initialized" do
      worker.instance_eval { @uid = nil }
      expect { worker.candidate_courses_list }.to raise_error(RuntimeError, "User ID not found for candidate")
    end

    it "should get properly formatted candidate course list from fake Oracle MV", :if => SakaiData.test_data? do
      Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
      terms_feed = CanvasProvideCourseSite.new("238382").candidate_courses_list
      terms_feed.length.should == 1
      terms_feed[0][:name].should == "Fall 2013"
      feed = terms_feed[0][:classes]
      feed.length.should == 2
      bio1a = feed.select {|course| course[:course_number] == 'BIOLOGY 1A'}[0]
      bio1a.empty?.should be_false
      bio1a[:title].should == "General Biology Lecture"
      bio1a[:role].should == "Instructor"
      bio1a[:sections].length.should == 2
      bio1a[:sections][0][:is_primary_section].should be_true
      bio1a[:sections][1][:is_primary_section].should be_false

      cogsci = feed.select {|course| course[:course_number] == 'COG SCI C147'}[0]
      cogsci.empty?.should be_false
      cogsci[:title].should == "Language Disorders"
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
          :course_number => "ENGIN 7",
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
          :course_number => "MEC ENG 98",
          :slug => "mec_eng-98",
          :dept => 'MEC ENG',
          :title => "Supervised Independent Group Studies",
          :role => "Instructor",
          :sections => [
            { :ccn => rand(99999).to_s, :instruction_format => "GRP", :is_primary_section => true, :section_label => "GRP 015", :section_number => "015" }
          ]
        },
        {
          :course_number => "MEC ENG H194",
          :slug => "mec_eng-h194",
          :dept => 'MEC ENG',
          :title => "Honors Undergraduate Research",
          :role => "Instructor",
          :sections => [
            { :ccn => "#{@selected_cnns[0]}", :instruction_format => "IND", :is_primary_section => true, :section_label => "IND 015", :section_number => "015" }
          ]
        },
        {
          :course_number => "MEC ENG 297",
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
      expect { worker.filter_courses_by_ccns(@candidate_terms_list, 'summer-2011', @selected_cnns) }.to raise_error(ArgumentError, "No courses found!")
    end

    it "should filter courses data by POSTed CCN selection" do
      filtered = worker.filter_courses_by_ccns(@candidate_terms_list, @term_slug, @selected_cnns)
      filtered.length.should == 2
      filtered[0][:course_number].should == 'ENGIN 7'
      filtered[0][:dept].should == 'COMPSCI'
      filtered[0][:sections].length.should == 1
      filtered[0][:sections][0][:section_label].should == "DIS 102"
      filtered[1][:course_number].should == 'MEC ENG H194'
      filtered[1][:dept].should == 'MEC ENG'
      filtered[1][:sections].length.should == 1
      filtered[1][:sections][0][:section_label].should == "IND 015"
    end
  end

  describe "#generate_course_site_definition" do
    before do
      @course_data = {
          :course_number => "ENGIN 7",
           :dept => "ENGIN",
           :slug => "engin-7",
           :title =>
               "Introduction to Computer Programming for Scientists and Engineers",
           :role => "Instructor",
           :sections =>
               [{:ccn => "#{rand(99999)}",
                 :instruction_format => "DIS",
                 :is_primary_section => false,
                 :section_label => "DIS 102",
                 :section_number => "102"}]
      }
      @term_yr = '2013'
      @term_cd = 'D'
    end

    it "should raise exception when sis course id fails to generate" do
      canvas_provide_course_site.stub(:generate_unique_sis_course_id).and_return(nil)
      expect do
        canvas_provide_course_site.generate_course_site_definition(@term_yr, @term_cd, @subaccount, @course_data)
      end.to raise_error(RuntimeError, "Could not define new course site!")
    end

    it "should generate a Course import CSV row for the selected courses" do
      CanvasExistenceCheckProxy.any_instance.stub(:account_defined?).and_return(true)
      CanvasExistenceCheckProxy.any_instance.stub(:course_defined?).and_return(false)
      subaccount = worker.subaccount_for_department(@course_data[:dept])
      canvas_course = worker.generate_course_site_definition(@term_yr, @term_cd, subaccount, @course_data)
      canvas_course['course_id'].present?.should be_true
      canvas_course['course_id'].should == "CRS:ENGIN-7-2013-D"
      canvas_course['short_name'].should == 'ENGIN 7'
      canvas_course['long_name'].should == 'Introduction to Computer Programming for Scientists and Engineers'
      canvas_course['account_id'].should == 'ACCT:ENGIN'
      canvas_course['term_id'].should == 'TERM:2013-D'
      canvas_course['status'].should == 'active'
    end

    it "should generate a unique Course SIS ID for the selected courses" do
      # RSpec does not currently redefine any_instance class stubs: http://stackoverflow.com/questions/18092601/rspec-any-instance-stub-does-not-restub-old-instances
      stub_existence_check = double
      stub_existence_check.should_receive(:account_defined?).and_return(true)
      stub_existence_check.should_receive(:course_defined?).and_return(false)
      CanvasExistenceCheckProxy.stub(:new).and_return(stub_existence_check)

      subaccount = worker.subaccount_for_department(@course_data[:dept])
      first_canvas_course = worker.generate_course_site_definition(@term_yr, @term_cd, subaccount, @course_data)
      first_course_sis_id = first_canvas_course['course_id']
      stub_existence_check.should_receive(:course_defined?).twice do |id|
        id == first_course_sis_id
      end
      second_canvas_course = worker.generate_course_site_definition(@term_yr, @term_cd, subaccount, @course_data)
      second_course_sis_id = second_canvas_course['course_id']
      second_course_sis_id.present?.should be_true
      second_course_sis_id.should_not == first_course_sis_id
    end
  end

  describe "#generate_course_memberships" do
    it "generates membership hashes for instructor within each section" do
      section_rows = [
        {"section_id"=>"SEC:2013-D-26123", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47A SLF 001", "status"=>"active"},
        {"section_id"=>"SEC:2013-D-26125", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47B SLF 001", "status"=>"active"}
      ]
      instructor_row = {"user_id"=>"UID:1234", "login_id"=>"1234", "first_name"=>"John", "last_name"=>"Doe", "email"=>"johndoe@berkeley.edu", "status"=>"active"}
      result = canvas_provide_course_site.generate_course_memberships(section_rows, instructor_row)
      result.should be_an_instance_of Array
      result.count.should == 2
      result[0].should be_an_instance_of Hash
      result[1].should be_an_instance_of Hash
      result[0].should == {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26123", "status"=>"active"}
      result[1].should == {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26125", "status"=>"active"}
    end
  end

  describe "#generate_unique_sis_course_id" do
    it "should generate a standard sis course id when a canvas course does not already exist" do
      stub_existence_proxy = double
      stub_existence_proxy.stub(:course_defined?).and_return(false)
      result = canvas_provide_course_site.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      result.should == "CRS:ETH_STD-C73ABC-2015-F"
    end

    it "should return a unique course id when a canvas course already exists" do
      # emulate course defined already twice
      stub_existence_proxy = double
      stub_existence_proxy.stub(:course_defined?).and_return(true, true, false)
      SecureRandom.stub(:hex).and_return("e2383290", "697c834e")
      result = canvas_provide_course_site.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      result.should == "CRS:ETH_STD-C73ABC-2015-F-697C834E"
    end

    it "should raise exception if unique course id not generated after 20 attempts" do
      stub_existence_proxy = double
      course_defined_responses = (1..21).to_a.map {|e| true} # array of 20 true responses
      stub_existence_proxy.stub(:course_defined?).and_return(course_defined_responses)
      expect do
        canvas_provide_course_site.generate_unique_sis_course_id(stub_existence_proxy, "eth_std-c73abc", "2015", "F")
      end.to raise_error(CanvasProvideCourseSite::IdNotUniqueException)
    end
  end

  describe "#generate_section_definitions" do
    it "should raise exception if campus_section_data argument is empty" do
      expect do
        canvas_provide_course_site.generate_section_definitions('2013', 'D', 'CRS:ENGIN-7-2013-D', [])
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
          {:course_number => "ENGIN 7",
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
          {:course_number => "MEC ENG 98",
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
      CanvasExistenceCheckProxy.any_instance.stub(:section_defined?).and_return(false)
      canvas_sections_list = worker.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)
      canvas_sections_list.length.should == 3
      canvas_sections_list.each do |row|
        row['course_id'].should == sis_course_id
        row['status'].should == 'active'
        campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(row['section_id'])
        campus_section[:term_yr].should == term_yr
        campus_section[:term_cd].should == term_cd
        ccns.include?(campus_section[:ccn]).should be_true
      end
      canvas_sections_list[0]['name'].should == 'ENGIN 7 LEC 002'
      canvas_sections_list[1]['name'].should == 'ENGIN 7 DIS 102'
      canvas_sections_list[2]['name'].should == 'MEC ENG 98 GRP 015'
    end

    it "should generate a unique parsable Section SIS ID for the selected sections" do
      term_yr = '2013'
      term_cd = 'D'
      ccn = rand(99999).to_s
      courses_list = [
          {:course_number => "ENGIN 7",
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
      stub_existence_check.should_receive(:section_defined?).and_return(false)
      CanvasExistenceCheckProxy.stub(:new).and_return(stub_existence_check)

      first_canvas_section = worker.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)[0]
      first_canvas_section_id = first_canvas_section['section_id']

      stub_existence_check.should_receive(:section_defined?).twice do |id|
        id == first_canvas_section_id
      end

      second_canvas_section = worker.generate_section_definitions(term_yr, term_cd, sis_course_id, courses_list)[0]
      second_canvas_section_id = second_canvas_section['section_id']
      second_canvas_section_id.present?.should be_true
      second_canvas_section_id.should_not == first_canvas_section_id
      campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(second_canvas_section_id)
      campus_section[:term_yr].should == term_yr
      campus_section[:term_cd].should == term_cd
      campus_section[:ccn].should == ccn
    end
  end

  describe "#subaccount_for_department" do
    it "should return the subaccount if it exists in Canvas" do
      CanvasExistenceCheckProxy.any_instance.stub(:account_defined?).and_return(true)
      result = canvas_provide_course_site.subaccount_for_department('COMPSCI')
      result.should == "ACCT:COMPSCI"
    end

    it "should raise exception if the subaccount does not exist in Canvas" do
      CanvasExistenceCheckProxy.any_instance.stub(:account_defined?).and_return(false)
      expect { canvas_provide_course_site.subaccount_for_department('COMPSCI') }.to raise_error(RuntimeError, 'Could not find bCourses account for department COMPSCI')
    end
  end

  describe "#find_term" do
    before(:each) do
      term_codes_array = [
        {yr: '3026', cd: 'C', slug: "summer-3026"},
        {yr: '3026', cd: 'D', slug: "fall-3026"},
      ]
      canvas_provide_course_site.stub(:current_terms).and_return(term_codes_array)
    end

    it "should return term code hash when slug matches a current term code" do
      result = canvas_provide_course_site.find_term('fall-3026')
      result.should be_an_instance_of Hash
      result[:yr].should == "3026"
      result[:cd].should == "D"
      result[:slug].should == "fall-3026"
    end

    it "should raise exception when slug does not match a current term code" do
      expect { canvas_provide_course_site.find_term('winter-3011') }.to raise_error(ArgumentError, "term_slug does not match current term code")
    end
  end

  describe "#courses_list_from_ccns" do
    # Lock down to a known set of sections, either in the test DB or in real campus data.
    let(:term_codes_array) {
      SakaiData.test_data? ?
          [{yr: '2013', cd: 'D', slug: "fall-2013"}] :
          [{yr: '2013', cd: 'B', slug: "spring-2013"}]
    }
    before { canvas_provide_course_site.stub(:current_terms).and_return(term_codes_array)}
    it "formats section information for known CCNs" do
      good_ccns = [7309, 7366, 16171]
      bad_ccns = [919191]
      semesters_list = canvas_provide_course_site.courses_list_from_ccns(term_codes_array[0][:slug], (good_ccns + bad_ccns))
      expect(semesters_list.length).to eq 1
      classes_list = semesters_list[0][:classes]
      expect(classes_list.length).to eq 2
      bio_class = classes_list[0]
      expect(bio_class[:course_number]).to eq 'BIOLOGY 1A'
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
      Settings.cache.expiration.stub(:CanvasCourseProvisioningJobs).and_return(nil)
      expect { canvas_provide_course_site.save }.to raise_error(RuntimeError, "Unable to save. Cache expiration setting not present.")
    end

    it "raises exception if cache key not present" do
      canvas_provide_course_site.instance_eval { @cache_key = nil }
      expect { canvas_provide_course_site.save }.to raise_error(RuntimeError, "Unable to save. cache_key missing")
    end

    it "saves current state of job to global storage" do
      CanvasProvideCourseSite.stub(:unique_job_id).and_return('1383330151057')
      canvas_provide_course_site.save
      retrieved_job = CanvasProvideCourseSite.find(canvas_provide_course_site.job_id)
      retrieved_job.class.should == CanvasProvideCourseSite
      retrieved_job.uid.should == uid
      retrieved_job.status.should == 'New'
      retrieved_job.job_id.should == "canvas.courseprovision.#{uid}.1383330151057"
    end
  end

  describe "#complete_step" do
    it "adds step to completed steps log" do
      canvas_provide_course_site.complete_step("Did something awesome")
      canvas_provide_course_site.instance_eval { @completed_steps }.should == ["Did something awesome"]
    end

    it "saves state of background job" do
      canvas_provide_course_site.should_receive(:save).and_return(true)
      canvas_provide_course_site.complete_step("Did something awesome")
    end
  end

  describe "#to_json" do
    before do
      canvas_provide_course_site.instance_eval { @status = 'Error'}
      canvas_provide_course_site.instance_eval { @cache_key = 'canvas.courseprovision.1234.1383330151057'}
      canvas_provide_course_site.instance_eval { @completed_steps = ['step1 description', 'step2 description']}
    end

    it "returns hash containing course import job state" do
      result = canvas_provide_course_site.to_json
      result.should be_an_instance_of String
      json_result = JSON.parse(result)
      json_result['status'].should == 'Error'
      json_result['job_id'].should == 'canvas.courseprovision.1234.1383330151057'
      json_result['completed_steps'][0].should == 'step1 description'
      json_result['completed_steps'][1].should == 'step2 description'
      json_result['percent_complete'].should == 0.17
      json_result['course_site'].should_not be
      json_result['error'].should_not be
    end

    context "when job status is completed" do
      it "includes course site details" do
        canvas_provide_course_site.instance_eval do
          @status = 'Completed'
          @import_data['course_site_url'] = "https://example.com/courses/999"
          @import_data['course_site_short_name'] = "COMPSCI-10"
        end
        json_result = JSON.parse(canvas_provide_course_site.to_json)
        json_result['course_site'].should be_an_instance_of Hash
        json_result['course_site']['short_name'].should == "COMPSCI-10"
        json_result['course_site']['url'].should == "https://example.com/courses/999"
        json_result['error'].should_not be
      end
    end

    context "when job status is error" do
      it "includes error messages string" do
        canvas_provide_course_site.instance_eval do
          @status = 'Error'
          @errors << "Error Message 1"
          @errors << "Error Message 2"
        end
        json_result = JSON.parse(canvas_provide_course_site.to_json)
        json_result['error'].should == "Error Message 1; Error Message 2"
        json_result['course_site'].should_not be
      end
    end
  end

  describe "#job_id" do
    it "returns cache key" do
      job_id = canvas_provide_course_site.instance_eval { @cache_key }
      canvas_provide_course_site.job_id.should == job_id
    end
  end

end
