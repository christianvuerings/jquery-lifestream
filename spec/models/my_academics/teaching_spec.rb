require "spec_helper"

describe 'MyAcademics::Teaching' do

  it "should get properly formatted data from fake Oracle MV", :if => SakaiData.test_data? do
    Settings.sakai_proxy.academic_terms.stub(:student).and_return(nil)
    Settings.sakai_proxy.academic_terms.stub(:instructor).and_return(nil)

    feed = {}
    MyAcademics::Teaching.new("192517").merge(feed)
    feed.empty?.should be_false

    teaching = feed[:teaching]
    teaching.length.should == 2
    bio1a = teaching.select {|course| course[:course_number] == 'BIOLOGY 1A'}[0]
    bio1a.empty?.should be_false
    bio1a[:title].should == "General Biology Lecture"
    bio1a[:semesters].length.should == 2
    bio1a[:semesters][0][:name].should == "Fall 2013"
    bio1a[:semesters][0][:role].should == "Instructor"
    bio1a[:semesters][0][:sections].length.should == 2
    bio1a[:semesters][0][:sections][0][:is_primary_section].should be_true
    bio1a[:semesters][0][:sections][1][:is_primary_section].should be_false
    bio1a[:semesters][1][:name].should == "Spring 2012"
    bio1a[:semesters][1][:role].should == "Instructor"
    bio1a[:semesters][1][:sections].length.should == 1
    bio1a[:semesters][1][:sections][0][:is_primary_section].should be_false
    cogsci = teaching.select {|course| course[:course_number] == 'COG SCI C147'}[0]
    cogsci.empty?.should be_false
    cogsci[:title].should == "Language Disorders"
    cogsci[:semesters].length.should == 2
  end

end