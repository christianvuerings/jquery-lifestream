require "spec_helper"

describe CanvasProvideCourseSite do

  let(:canvas_provide_course_site)    { CanvasProvideCourseSite.new(user_id: rand(99999).to_s) }
  let(:worker)                        { canvas_provide_course_site }

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

  describe "#create_course_site" do
    before do
      # Stub all dependencies
      canvas_provide_course_site.stub(:find_term).and_return({yr: '2013', cd: 'D', slug: "fall-2013"})
      filtered_courses = [{
        :course_number=>"COMPSCI 10",
        :dept=>"COMPSCI",
        :slug=>"compsci-10",
        :title=>"The Beauty and Joy of Computing",
        :role=>"Instructor",
        :sections=>[
          {:ccn=>"1136", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:building_name=>"SODA", :room_number=>"0320", :schedule=>"M 8:00A-9:00A"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]},
          {:ccn=>"1204", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 109", :section_number=>"109", :schedules=>[{:building_name=>"SODA", :room_number=>"0320", :schedule=>"M 12:00P-1:00P"}], :instructors=>[{:name=>"Seth Mark Beckley", :uid=>"937403"}]}
        ]
      }]
      canvas_provide_course_site.stub(:filter_courses_by_ccns).and_return(filtered_courses)

      canvas_section_rows = {"section_id"=>"SEC:2013-D-33866", "course_id"=>"CRS:COMPSCI-10-2013-D", "name"=>"ENGIN 7 DIS 102", "status"=>"active"}
      canvas_provide_course_site.stub(:generate_section_definitions).and_return(canvas_section_rows)

      canvas_provide_course_site.stub(:subaccount_for_department).and_return('ACCCT:COMPSCI')
      canvas_course_row = {
        "course_id"=>"CRS:COMPSCI-10-2013-D",
        "short_name"=>"COMPSCI 10 DIS 102",
        "long_name"=>"The Beauty and Joy of Computing",
        "account_id"=>"ACCT:COMPSCI",
        "term_id"=>"TERM:2013-D",
        "status"=>"active"
      }
      canvas_provide_course_site.stub(:generate_course_site_definition).and_return(canvas_course_row)

      membership_rows = [{"course_id"=>"CRS:COMPSCI-10-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-33866", "status"=>"active"}]
      canvas_provide_course_site.stub(:generate_course_memberships).and_return(membership_rows)

      canvas_provide_course_site.stub(:import_course).and_return({created_status: 'Success'})
      canvas_provide_course_site.stub(:course_site_url).and_return("https://berkeley.instructure.com/courses/1253733")
    end

    it "returns error if course import fails" do
      canvas_provide_course_site.stub(:import_course).and_return({created_status: 'ERROR', created_message: 'Course site could not be created!'})
      result = canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"])
      result.should be_an_instance_of Hash
      result[:created_status].should == 'ERROR'
      result[:created_message].should == 'Course site could not be created!'
    end

    it "creates a course site" do
      result = canvas_provide_course_site.create_course_site("fall-2013", ["1136", "1204"])
      result.should be_an_instance_of Hash
      result[:created_status].should == "Success"
      result["created_course_site_url"].should == "https://berkeley.instructure.com/courses/1253733"
      result["created_course_site_short_name"].should == "COMPSCI 10 DIS 102"
    end
  end

  describe "#candidate_courses_list" do
    it "should get properly formatted candidate course list from fake Oracle MV", :if => SakaiData.test_data? do
      Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
      terms_feed = CanvasProvideCourseSite.new(user_id: "192517").candidate_courses_list
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
          :title => "Supervised Independent Group Studies",
          :role => "Instructor",
          :sections => [
            { :ccn => rand(99999).to_s, :instruction_format => "GRP", :is_primary_section => true, :section_label => "GRP 015", :section_number => "015" }
          ]
        },
        {
          :course_number => "MEC ENG H194",
          :slug => "mec_eng-h194",
          :title => "Honors Undergraduate Research",
          :role => "Instructor",
          :sections => [
            { :ccn => "#{@selected_cnns[0]}", :instruction_format => "IND", :is_primary_section => true, :section_label => "IND 015", :section_number => "015" }
          ]
        },
        {
          :course_number => "MEC ENG 297",
          :slug => "mec_eng-297",
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
      filtered[0][:sections].length.should == 1
      filtered[0][:sections][0][:section_label].should == "DIS 102"
      filtered[1][:course_number].should == 'MEC ENG H194'
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
      canvas_course['short_name'].should == 'ENGIN 7 DIS 102'
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
      worker = CanvasProvideCourseSite.new(user_id: rand(99999).to_s)
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

      worker = CanvasProvideCourseSite.new(user_id: rand(99999).to_s)
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

  describe "#import_course" do
    before do
      @canvas_sis_import_proxy_stub = double
      @canvas_sis_import_proxy_stub.stub(:import_courses).and_return(true)
      @canvas_sis_import_proxy_stub.stub(:import_sections).and_return(true)
      @canvas_sis_import_proxy_stub.stub(:import_users).and_return(true)
      @canvas_sis_import_proxy_stub.stub(:import_enrollments).and_return(true)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)

      @course_row = {"course_id"=>"CRS:COMPSCI-47A-2013-D", "short_name"=>"COMPSCI 47A SLF 001", "long_name"=>"Completion of Work in Computer Science 61A", "account_id"=>"ACCT:COMPSCI", "term_id"=>"TERM:2013-D", "status"=>"active"}
      @section_rows = [
        {"section_id"=>"SEC:2013-D-26178", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47A SLF 001", "status"=>"active"},
        {"section_id"=>"SEC:2013-D-26181", "course_id"=>"CRS:COMPSCI-47A-2013-D", "name"=>"COMPSCI 47B SLF 001", "status"=>"active"}
      ]
      @user_rows = [{"user_id"=>"UID:1234", "login_id"=>"1234", "first_name"=>"John", "last_name"=>"Smith", "email"=>"johnsmith@berkeley.edu", "status"=>"active"}]
      @enrollment_rows   = [
        {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26178", "status"=>"active"},
        {"course_id"=>"CRS:COMPSCI-47A-2013-D", "user_id"=>"UID:1234", "role"=>"teacher", "section_id"=>"SEC:2013-D-26181", "status"=>"active"}
      ]
    end

    it "raises exception if course import fails" do
      @canvas_sis_import_proxy_stub.stub(:import_courses).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      expect do
        canvas_provide_course_site.import_course(@course_row, @section_rows, @user_rows, @enrollment_rows)
      end.to raise_error(RuntimeError, "Course site could not be created!")
    end

    it "returns warning when section import fails" do
      @canvas_sis_import_proxy_stub.stub(:import_sections).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      result = canvas_provide_course_site.import_course(@course_row, @section_rows, @user_rows, @enrollment_rows)
      result.should == {created_status: 'WARNING', created_message: 'Course site was created without any sections or members!'}
    end

    it "returns warning when user import fails" do
      @canvas_sis_import_proxy_stub.stub(:import_users).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      result = canvas_provide_course_site.import_course(@course_row, @section_rows, @user_rows, @enrollment_rows)
      result.should == {created_status: 'WARNING', created_message: 'Course site was created but members may be missing!'}
    end

    it "returns warning when user enrollment fails" do
      @canvas_sis_import_proxy_stub.stub(:import_enrollments).and_return(nil)
      CanvasSisImportProxy.stub(:new).and_return(@canvas_sis_import_proxy_stub)
      result = canvas_provide_course_site.import_course(@course_row, @section_rows, @user_rows, @enrollment_rows)
      result.should == {created_status: 'WARNING', created_message: 'Course site was created but members may not be enrolled!'}
    end

    it "returns success when course successfully imported" do
      result = canvas_provide_course_site.import_course(@course_row, @section_rows, @user_rows, @enrollment_rows)
      result.should == {created_status: 'Success'}
    end
  end

  describe "#response_hash" do
    it "should raise exception if status argument is not a string" do
      expect { canvas_provide_course_site.response_hash(123, 'error msg') }.to raise_error(ArgumentError, "String type expected")
    end

    it "should raise exception if message argument is not a string" do
      expect { canvas_provide_course_site.response_hash('ERROR', 123) }.to raise_error(ArgumentError, "String type expected")
    end

    it "should return hash with status and message" do
      result = canvas_provide_course_site.response_hash('ERROR', "I'm sorry Dave, I'm afraid I can't do that")
      result.should be_an_instance_of Hash
      result[:created_status].should == "ERROR"
      result[:created_message].should == "I'm sorry Dave, I'm afraid I can't do that"
    end

    it "should return hash with only status when no message argument" do
      result = canvas_provide_course_site.response_hash('Success')
      result.should be_an_instance_of Hash
      result[:created_status].should == "Success"
      result.has_key?(:created_message).should be_false
    end
  end

end
