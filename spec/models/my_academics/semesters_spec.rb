require "spec_helper"

describe "MyAcademics::Semesters", :if => SakaiData.test_data? do
  let!(:oski_schedule_proxy) { CampusUserCoursesProxy.new({:fake => true}) }

  context "should get properly formatted data from fake Oracle MV" do
    before(:each) do
      Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
      Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
      #Use this to tinker with the time buckets
      Settings.sakai_proxy.stub(:current_terms_codes).and_return([OpenStruct.new(term_yr: "2013", term_cd: "D")])
      CampusUserCoursesProxy.stub(:new).and_return(oski_schedule_proxy)
    end

    subject { MyAcademics::Semesters.new("300939").merge(@feed ||= {}); @feed }

    it { should_not be_empty }

    context "semesters" do

      subject { MyAcademics::Semesters.new("300939").merge(@feed ||= {}); @feed[:semesters] }

      it { subject.length.should eq(4) }
      it { subject[0][:name].should eq "Spring 2015" }
      it { subject[0][:time_bucket].should eq 'future'}
      it { subject[0][:classes].length.should eq 1 }
      it { subject[0][:classes][0][:course_number].should eq "BIOLOGY 1A" }
      it { subject[0][:classes][0][:grade_option].should eq "P/NP" }
      it { subject[0][:classes][0][:sections].length.should eq 1 }
      it { subject[0][:classes][0][:sections][0][:ccn].should eq "7309" }
      it { subject[0][:classes][0][:sections][0][:waitlist_position].should eq "42" }
      it { subject[0][:classes][0][:sections][0][:enroll_limit].should eq "5000" }
      it { subject[1][:name].should eq "Spring 2014" }
      it { subject[1][:time_bucket].should eq 'future'}
      it { subject[2][:name].should eq "Fall 2013"}
      it { subject[2][:time_bucket].should eq 'current' }
      it { subject[3][:name].should eq "Spring 2012" }
      it { subject[3][:time_bucket].should eq 'past' }
      it { subject[2][:classes].length.should eq 2 }
      it { subject[2][:classes][0][:course_number].should eq "BIOLOGY 1A" }
      it { subject[2][:classes][0][:sections].length.should eq 2 }
      it { subject[2][:classes][0][:sections][0][:ccn].should eq "7309" }
      it { subject[2][:classes][0][:sections][0][:schedules][0][:schedule].should eq "M 4:00P-5:00P" }
      it { subject[2][:classes][0][:slug].should eq "biology-1a" }
      it { subject[2][:classes][0][:grade].should be_nil }
      it { subject[2][:classes][0][:title].should eq "General Biology Lecture" }
      it { subject[2][:classes][0][:units].should eq "5.0" }
      it { subject[2][:classes][0][:grade_option].should eq "Letter" }
      it { subject[2][:classes][0][:sections][0][:instruction_format].should eq "LEC" }
      it { subject[2][:classes][0][:sections][0][:section_number].should eq "003" }
      it { subject[2][:classes][0][:sections][0][:section_label].should eq "LEC 003" }
      it { subject[2][:classes][0][:sections][0][:instructors][0][:name].should eq "Yu-Hung Lin" }
      it { subject[2][:classes][0][:sections][0][:is_primary_section].should be_true }
      it { subject[3][:classes][0][:grade].should eq "B" }
      it { subject[3][:classes][0][:units].should eq "4.0" }
      it { subject[3][:classes][1][:grade].should eq "C+" }
      it { subject[3][:classes][1][:units].should eq "3.0" }
    end
  end

  context "should be able to constrain semester range" do
    before(:each) do
      Settings.sakai_proxy.academic_terms.stub(:student).and_return(terms_constraint)
      Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(terms_constraint)
      CampusUserCoursesProxy.stub(:new).and_return(oski_schedule_proxy)
    end

    let(:terms_constraint) { Settings.sakai_proxy.current_terms_codes }

    subject { MyAcademics::Semesters.new("300939").merge(@feed ||= {}); @feed }

    it { should_not be_empty }
    it { subject[:semesters].length.should eq terms_constraint.length }
  end

  context "should handle badly formatted p/np fields for course data" do
    before(:each) do
      Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
      Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)
      oski_campus_courses = CampusUserCoursesProxy.new({:fake => true}).get_all_campus_courses
      oski_campus_courses.values.each do |semester|
        semester.each do |course|
          course[:pnp_flag] = nil
        end
      end
      CampusUserCoursesProxy.any_instance.stub(:get_all_campus_courses).and_return(oski_campus_courses)
    end

    subject { MyAcademics::Semesters.new("300939").merge(@feed ||= {}); @feed }

    it { should_not be_empty}
    it { subject[:semesters].length.should eq 4}
    it { subject[:semesters][0][:name].should == "Spring 2015" }
    it { subject[:semesters][0][:classes].length.should == 1 }
    it { subject[:semesters][0][:classes][0][:grade_option].should == '' }
    it { subject[:semesters][1][:name].should == "Spring 2014" }
    it { subject[:semesters][1][:classes][0][:grade_option].should == '' }
  end

end
