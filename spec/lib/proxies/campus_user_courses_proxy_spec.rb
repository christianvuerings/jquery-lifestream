require "spec_helper"

describe CampusUserCoursesProxy do

  it "should be accessible if non-null user" do
    CampusUserCoursesProxy.access_granted?(nil).should be_false
    CampusUserCoursesProxy.access_granted?('211159').should be_true
    client = CampusUserCoursesProxy.new({user_id: '211159'})
    client.get_campus_courses.should_not be_nil
  end

  it "should return pre-populated test enrollments for current semesters", :if => SakaiData.test_data? do
    client = CampusUserCoursesProxy.new({user_id: '300939'})
    courses = client.get_campus_courses
    courses.empty?.should be_false
    courses.each do |course|
      course[:id].blank?.should be_false
      course[:emitter].should == 'Campus'
      course[:name].blank?.should be_false
      ['Student', 'Instructor'].include?(course[:role]).should be_true
      sections = course[:sections]
      sections.length.should be > 0
      sections.each do |section|
        if section[:ccn] == "16171"
          section[:instruction_format].blank?.should be_false
          section[:section_number].blank?.should be_false
          section[:instructors].length.should == 1
          section[:instructors][0][:name].present?.should be_true
          section[:schedules][0][:schedule].should == "TuTh 2:00P-3:30P"
          section[:schedules][0][:building_name].should == "WHEELER"
        end
      end
    end
  end

  it "should return pre-populated test enrollments for all semesters", :if => SakaiData.test_data? do
    Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
    Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
    client = CampusUserCoursesProxy.new({user_id: '300939'})
    courses = client.get_all_campus_courses
    courses.empty?.should be_false
    courses["2012-B"].length.should == 2
    courses["2013-D"].length.should == 2
    courses["2013-D"].each do |course|
      course[:id].blank?.should be_false
      course[:emitter].should == 'Campus'
      course[:name].blank?.should be_false
      course.should be_has_key(:cred_cd)
      ['Student', 'Instructor'].include?(course[:role]).should be_true
      sections = course[:sections]
      sections.length.should be > 0
      sections.each do |section|
        if section[:ccn] == "16171"
          section[:instruction_format].blank?.should be_false
          section[:section_number].blank?.should be_false
          section[:instructors].length.should == 1
          section[:instructors][0][:name].present?.should be_true
          section[:schedules][0][:schedule].should == "TuTh 2:00P-3:30P"
          section[:schedules][0][:building_name].should == "WHEELER"
        end
      end
    end
  end

  it "should say that Tammi has student history", :if => SakaiData.test_data? do
    client = CampusUserCoursesProxy.new({user_id: '300939'})
    client.has_student_history?.should be_true
  end

  it "should say that our fake teacher has instructor history", :if => SakaiData.test_data? do
    client = CampusUserCoursesProxy.new({user_id: '238382'})
    client.has_instructor_history?.should be_true
  end

end
