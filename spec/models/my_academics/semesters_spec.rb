require "spec_helper"

describe "MyAcademics::Semesters" do

  it "should get properly formatted data from fake Oracle MV", :if => SakaiData.test_data? do
    oski_schedule_proxy = CampusUserCoursesProxy.new({:fake => true})
    CampusUserCoursesProxy.stub(:new).and_return(oski_schedule_proxy)

    feed = {}
    MyAcademics::Semesters.new("300939").merge(feed)
    feed.empty?.should be_false

    feed[:current_semester_index].should == 1
    oski_semesters = feed[:semesters]
    oski_semesters.length.should == 3
    oski_semesters[0][:name].should == "Spring 2014"
    oski_semesters[0][:time_bucket].should == 'future'
    oski_semesters[1][:name].should == "Fall 2013"
    oski_semesters[1][:time_bucket].should == 'current'
    oski_semesters[2][:name].should == "Spring 2012"
    oski_semesters[2][:time_bucket].should == 'past'
    oski_semesters[1][:schedule].length.should == 3
    oski_semesters[1][:schedule][0][:schedules][0][:schedule].should == "M 4:00P-5:00P"
    oski_semesters[1][:schedule][0][:course_number].should == "BIOLOGY 1A"
    oski_semesters[1][:schedule][0][:ccn].should == "7309"
    oski_semesters[1][:schedule][0][:grade].should be_nil
    oski_semesters[1][:schedule][0][:title].should == "General Biology Lecture"
    oski_semesters[1][:schedule][0][:units].should == "5.0"
    oski_semesters[1][:schedule][0][:grade_option].should == "Letter"
    oski_semesters[1][:schedule][0][:format].should == "LEC"
    oski_semesters[1][:schedule][0][:section].should == "003"
    oski_semesters[1][:schedule][0][:instructors][0][:name].should == "Yu-Hung Lin"
    oski_semesters[1][:schedule][0][:is_primary_section].should be_true
    oski_semesters[2][:schedule][0][:grade].should == "B"
    oski_semesters[2][:schedule][1][:grade].should == "C+"

  end

  it "should handle badly formatted p/np fields for course data", :if => SakaiData.test_data? do
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
    oski_semesters[0][:schedule].length.should == 1
    oski_semesters[0][:schedule][0][:grade_option].should == ''
    oski_semesters[1][:name].should == "Fall 2013"
    oski_semesters[1][:schedule][0][:grade_option].should == ''
  end

end
