require "spec_helper"

describe "MyAcademics::Semesters" do

  it "should get properly formatted data from fake Oracle MV", :if => SakaiData.test_data? do
    Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
    Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
    oski_schedule_proxy = CampusUserCoursesProxy.new({:fake => true})
    CampusUserCoursesProxy.stub(:new).and_return(oski_schedule_proxy)

    feed = {}
    MyAcademics::Semesters.new("300939").merge(feed)
    feed.empty?.should be_false

    oski_semesters = feed[:semesters]
    oski_semesters.length.should == 3
    oski_semesters[0][:name].should == "Spring 2014"
    oski_semesters[0][:time_bucket].should == 'future'
    oski_semesters[1][:name].should == "Fall 2013"
    oski_semesters[1][:time_bucket].should == 'current'
    oski_semesters[2][:name].should == "Spring 2012"
    oski_semesters[2][:time_bucket].should == 'past'
    oski_semesters[1][:classes].length.should == 2
    oski_semesters[1][:classes][0][:course_number].should == "BIOLOGY 1A"
    oski_semesters[1][:classes][0][:sections].length.should == 2
    oski_semesters[1][:classes][0][:sections][0][:ccn].should == "7309"
    oski_semesters[1][:classes][0][:sections][0][:schedules][0][:schedule].should == "M 4:00P-5:00P"
    oski_semesters[1][:classes][0][:slug].should == "biology-1a"
    oski_semesters[1][:classes][0][:grade].should be_nil
    oski_semesters[1][:classes][0][:title].should == "General Biology Lecture"
    oski_semesters[1][:classes][0][:units].should == "5.0"
    oski_semesters[1][:classes][0][:grade_option].should == "Letter"
    oski_semesters[1][:classes][0][:sections][0][:instruction_format].should == "LEC"
    oski_semesters[1][:classes][0][:sections][0][:section_number].should == "003"
    oski_semesters[1][:classes][0][:sections][0][:section_label].should == "LEC 003"
    oski_semesters[1][:classes][0][:sections][0][:instructors][0][:name].should == "Yu-Hung Lin"
    oski_semesters[1][:classes][0][:sections][0][:is_primary_section].should be_true
    oski_semesters[2][:classes][0][:grade].should == "B"
    oski_semesters[2][:classes][0][:units].should == "4.0"
    oski_semesters[2][:classes][1][:grade].should == "C+"
    oski_semesters[2][:classes][1][:units].should == "3.0"

  end

  it "should be able to constrain semester range", :if => SakaiData.test_data? do
    terms_constraint = Settings.sakai_proxy.current_terms_codes
    Settings.sakai_proxy.academic_terms.stub(:student).and_return(terms_constraint)
    Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(terms_constraint)
    oski_schedule_proxy = CampusUserCoursesProxy.new({:fake => true})
    CampusUserCoursesProxy.stub(:new).and_return(oski_schedule_proxy)
    feed = {}
    MyAcademics::Semesters.new("300939").merge(feed)
    feed.empty?.should be_false
    oski_semesters = feed[:semesters]
    oski_semesters.length.should == terms_constraint.length
  end

  it "should handle badly formatted p/np fields for course data", :if => SakaiData.test_data? do
    Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
    Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
    oski_campus_courses = CampusUserCoursesProxy.new({:fake => true}).get_all_campus_courses
    oski_campus_courses.values.each do |semester|
      semester.each do |course|
        course[:pnp_flag] = nil
      end
    end
    CampusUserCoursesProxy.any_instance.stub(:get_all_campus_courses).and_return(oski_campus_courses)

    feed = {}
    MyAcademics::Semesters.new("300939").merge(feed)
    feed.empty?.should be_false
    oski_semesters = feed[:semesters]
    oski_semesters.length.should == 3
    oski_semesters[0][:name].should == "Spring 2014"
    oski_semesters[0][:classes].length.should == 1
    oski_semesters[0][:classes][0][:grade_option].should == ''
    oski_semesters[1][:name].should == "Fall 2013"
    oski_semesters[1][:classes][0][:grade_option].should == ''
  end

end
