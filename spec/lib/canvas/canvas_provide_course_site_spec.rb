require "spec_helper"

describe CanvasProvideCourseSite do

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

  # TODO it "should show which sections already have Canvas course sites" do

  it "should filter courses data by POSTed CCN selection" do
    selected_cnns = [
        rand(99999).to_s,
        rand(99999).to_s
    ]
    candidate_courses_list = [
        {:course_number => "ENGIN 7",
         :slug => "engin-7",
         :title =>
             "Introduction to Computer Programming for Scientists and Engineers",
         :role => "Instructor",
         :sections =>
             [{:ccn => rand(99999).to_s,
               :instruction_format => "LEC",
               :is_primary_section => true,
               :section_label => "LEC 002",
               :section_number => "002"},
              {:ccn => "#{selected_cnns[1]}",
               :instruction_format => "DIS",
               :is_primary_section => false,
               :section_label => "DIS 102",
               :section_number => "102"}]},
        {:course_number => "MEC ENG 98",
         :slug => "mec_eng-98",
         :title => "Supervised Independent Group Studies",
         :role => "Instructor",
         :sections =>
             [{:ccn => rand(99999).to_s,
               :instruction_format => "GRP",
               :is_primary_section => true,
               :section_label => "GRP 015",
               :section_number => "015"}]},
        {:course_number => "MEC ENG H194",
         :slug => "mec_eng-h194",
         :title => "Honors Undergraduate Research",
         :role => "Instructor",
         :sections =>
             [{:ccn => "#{selected_cnns[0]}",
               :instruction_format => "IND",
               :is_primary_section => true,
               :section_label => "IND 015",
               :section_number => "015"}]},
        {:course_number => "MEC ENG 297",
         :slug => "mec_eng-297",
         :title => "Engineering Field Studies",
         :role => "Instructor",
         :sections =>
             [{:ccn => rand(99999).to_s,
               :instruction_format => "IND",
               :is_primary_section => true,
               :section_label => "IND 024",
               :section_number => "024"}]}
    ]
    term_slug = 'fall-2013'
    candidate_terms_list = [
        {
            name: 'Fall 2013',
            slug: term_slug,
            classes: candidate_courses_list
        }
    ]
    worker = CanvasProvideCourseSite.new(user_id: rand(99999).to_s)
    filtered = worker.filter_courses_by_ccns(candidate_terms_list, term_slug, selected_cnns)
    filtered.length.should == 2
    filtered[0][:course_number].should == 'ENGIN 7'
    filtered[0][:sections].length.should == 1
    filtered[0][:sections][0][:section_label].should == "DIS 102"
    filtered[1][:course_number].should == 'MEC ENG H194'
    filtered[1][:sections].length.should == 1
    filtered[1][:sections][0][:section_label].should == "IND 015"
  end

  it "should generate a Course import CSV row for the selected courses" do
    term_yr = '2013'
    term_cd = 'D'
    CanvasExistenceCheckProxy.any_instance.stub(:account_defined?).and_return(true)
    CanvasExistenceCheckProxy.any_instance.stub(:course_defined?).and_return(false)
    course_data = {
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
    worker = CanvasProvideCourseSite.new(user_id: rand(99999).to_s)
    canvas_course = worker.generate_course_site_definition(term_yr, term_cd,
      worker.subaccount_for_department(course_data[:dept]),
      course_data)
    canvas_course['course_id'].present?.should be_true
    canvas_course['short_name'].should == 'ENGIN 7 DIS 102'
    canvas_course['long_name'].should == 'Introduction to Computer Programming for Scientists and Engineers'
    canvas_course['account_id'].should == 'ACCT:ENGIN'
    canvas_course['term_id'].should == 'TERM:2013-D'
    canvas_course['status'].should == 'active'
  end

  it "should generate a unique Course SIS ID for the selected courses" do
    term_yr = '2013'
    term_cd = 'D'
    course_data = {
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
    worker = CanvasProvideCourseSite.new(user_id: rand(99999).to_s)

    # RSpec does not currently redefine any_instance class stubs: http://stackoverflow.com/questions/18092601/rspec-any-instance-stub-does-not-restub-old-instances
    stub_existence_check = double
    stub_existence_check.should_receive(:account_defined?).and_return(true)
    stub_existence_check.should_receive(:course_defined?).and_return(false)
    CanvasExistenceCheckProxy.stub(:new).and_return(stub_existence_check)

    subaccount = worker.subaccount_for_department(course_data[:dept])
    first_canvas_course = worker.generate_course_site_definition(term_yr, term_cd, subaccount, course_data)
    first_course_sis_id = first_canvas_course['course_id']
    stub_existence_check.should_receive(:course_defined?).twice do |id|
      id == first_course_sis_id
    end
    second_canvas_course = worker.generate_course_site_definition(term_yr, term_cd, subaccount, course_data)
    second_course_sis_id = second_canvas_course['course_id']
    second_course_sis_id.present?.should be_true
    second_course_sis_id.should_not == first_course_sis_id
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
