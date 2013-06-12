require "spec_helper"

describe CanvasRefreshFromCampus do

  before do
    @fake_sections_report_proxy = CanvasAccountSectionsReportProxy.new({fake: true})
  end

  it "should extract SIS-integrated sections from CSV" do
    CanvasAccountSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    worker = CanvasRefreshFromCampus.new
    test_term_id = CanvasProxy.current_sis_term_ids[0]
    canvas_sections = worker.get_all_sis_sections_for_term(test_term_id)
    canvas_sections.nil?.should be_false
    canvas_sections.each do |cs|
      cs[:section_id].blank?.should be_false
      cs[:course_id].blank?.should be_false
      cs[:term_id].blank?.should be_false
    end
  end

  it "should accumulate section enrollments and users for known sections", :if => SakaiData.test_data? do
    CanvasAccountSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    worker = CanvasRefreshFromCampus.new
    test_term_id = CanvasProxy.current_sis_term_ids[0]
    canvas_sections = worker.get_all_sis_sections_for_term(test_term_id)
    user_ids = Set.new
    enrollments = []
    canvas_sections.each do |cs|
      worker.accumulate_section_enrollments(cs, enrollments, user_ids)
      worker.accumulate_section_instructors(cs, enrollments, user_ids)
    end
    enrollments.length.should == 5
    (enrollments.select {|r| r['role'] == 'student'}).length.should == 2
    (enrollments.select {|r| r['role'] == 'teacher'}).length.should == 3
    user_ids.length.should == 3
    user_data = []
    worker.accumulate_user_data(user_ids, user_data)
    user_data.length.should == user_ids.length
  end

  it "should be able to get a whole lot of user records" do
    known_first = ['192517', '238382', '2040']
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
    CanvasAccountSectionsReportProxy.stub(:new).and_return(@fake_sections_report_proxy)
    fake_import_proxy = CanvasSisImportProxy.new({fake: true})
    CanvasSisImportProxy.stub(:new).and_return(fake_import_proxy)
    fake_import_proxy.should_receive(:generate_course_sis_id).with('1093165').and_call_original
    worker = CanvasRefreshFromCampus.new
    worker.repair_sis_ids_for_term(CanvasProxy.current_sis_term_ids[0])
  end

end
