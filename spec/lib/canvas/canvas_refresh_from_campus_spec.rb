require "spec_helper"

describe CanvasRefreshFromCampus do

  before do
    @fake_sections_report_proxy = CanvasSectionsReportProxy.new({fake: true})
  end

  it "should extract SIS-integrated sections from CSV" do
    CanvasSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    worker = CanvasRefreshFromCampus.new
    test_term_id = CanvasProxy.current_sis_term_ids[1]
    canvas_sections = worker.get_all_sis_sections_for_term(test_term_id)
    canvas_sections.nil?.should be_false
    canvas_sections.each do |cs|
      cs[:section_id].blank?.should be_false
      cs[:course_id].blank?.should be_false
      cs[:term_id].blank?.should be_false
    end
  end

  it "should accumulate section enrollments and users for known sections", :if => SakaiData.test_data? do
    CanvasSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    worker = CanvasRefreshFromCampus.new
    test_term_id = CanvasProxy.current_sis_term_ids[1]
    canvas_sections = worker.get_all_sis_sections_for_term(test_term_id)
    user_ids = Set.new
    enrollments = []
    users = []
    canvas_sections.each do |cs|
      worker.accumulate_section_enrollments(cs, enrollments, users)
      worker.accumulate_section_instructors(cs, enrollments, users)
    end
    enrollments.length.should == 5
    (enrollments.select {|r| r['role'] == 'student'}).length.should == 2
    (enrollments.select {|r| r['role'] == 'teacher'}).length.should == 3
    users.uniq!
    users.length.should == 3
  end

  it "should be able to get a whole lot of user records" do
    known_first = ['238382', '2040']
    known_last = ['3060', '211159', '322279']
    lotsa = []
    lotsa.concat(known_first)
    (1..1000).each {|u| lotsa << u}
    lotsa.concat(known_last)
    user_data = []
    worker = CanvasRefreshFromCampus.new
    worker.accumulate_user_data(lotsa, user_data)
    known_users = user_data.select do |row|
      known_first.include?(row['login_id']) || known_last.include?(row['login_id'])
    end
    known_users.length.should == (known_first.length + known_last.length)
  end

  it "should be able to add missing course SIS IDs" do
    CanvasSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    fake_import_proxy = CanvasSisImportProxy.new({fake: true})
    CanvasSisImportProxy.stub(:new).and_return(fake_import_proxy)
    fake_import_proxy.should_receive(:generate_course_sis_id).with('1093165').and_call_original
    worker = CanvasRepairSections.new
    worker.repair_sis_ids_for_term(CanvasProxy.current_sis_term_ids[1])
  end

  it "should distinguish waitlisted students" do
    enrolled = rand(99999)
    waitlisted = rand(99999)
    concurrent = rand(99999)
    dropped = rand(99999)
    CampusData.stub(:get_enrolled_students).and_return(
        [
            {
                'ldap_uid' => enrolled,
                'enroll_status' => 'E',
                'student_id' => enrolled,
                'affiliations' => 'STUDENT-TYPE-REGISTERED'
            },
            {
                'ldap_uid' => waitlisted,
                'enroll_status' => 'W',
                'student_id' => waitlisted,
                'affiliations' => 'STUDENT-TYPE-REGISTERED'
            },
            {
                'ldap_uid' => concurrent,
                'enroll_status' => 'C',
                'student_id' => concurrent,
                'affiliations' => 'STUDENT-TYPE-REGISTERED'
            },
            {
                'ldap_uid' => dropped,
                'enroll_status' => 'D',
                'student_id' => dropped,
                'affiliations' => 'STUDENT-TYPE-REGISTERED'
            }
        ]
    )
    enrollments = []
    users = []
    worker = CanvasRefreshFromCampus.new
    worker.accumulate_section_enrollments({section_id: "SEC:2013-C-333"}, enrollments, users)
    enrollments.length.should == 3
    users.uniq.length.should == 3
    enrollments.index {|enr| enr['user_id'] == enrolled.to_s && enr['role'] == 'student'}.should_not be_nil
    enrollments.index {|enr| enr['user_id'] == concurrent.to_s && enr['role'] == 'student'}.should_not be_nil
    enrollments.index {|enr| enr['user_id'] == waitlisted.to_s && enr['role'] == 'Waitlist Student'}.should_not be_nil
    enrollments.index {|enr| enr['user_id'] == dropped.to_s}.should be_nil
  end

end
