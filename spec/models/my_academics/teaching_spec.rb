require "spec_helper"

describe 'MyAcademics::Teaching' do

  it "should get properly formatted data from fake Oracle MV", :if => CampusOracle::Connection.test_data? do
    feed = {}
    MyAcademics::Teaching.new("238382").merge(feed)
    feed.empty?.should be_falsey

    teaching = feed[:teachingSemesters]
    teaching.length.should == 2
    teaching[0][:name].should == "Fall 2013"
    teaching[0][:termCode].should == "D"
    teaching[0][:termYear].should == "2013"

    teaching[0][:classes].length.should == 2
    bio1a = teaching[0][:classes].select {|course| course[:course_code] == 'BIOLOGY 1A'}[0]
    bio1a.empty?.should be_falsey
    bio1a[:dept].should eq "BIOLOGY"
    bio1a[:title].should == "General Biology Lecture"
    bio1a[:role].should == "Instructor"
    bio1a[:sections].length.should == 3
    bio1a[:sections][0][:is_primary_section].should be_truthy
    bio1a[:sections][1][:is_primary_section].should be_falsey
    bio1a[:sections][2][:is_primary_section].should be_falsey
    bio1a[:url].should == '/academics/teaching-semester/fall-2013/class/biology-1a'

    cogsci = teaching[0][:classes].select {|course| course[:course_code] == 'COG SCI C147'}[0]
    cogsci.empty?.should be_falsey
    cogsci[:dept].should == "COG SCI"
    cogsci[:title].should == "Language Disorders"
    cogsci[:url].should == '/academics/teaching-semester/fall-2013/class/cog_sci-c147'

    teaching[1][:name].should == "Spring 2012"
    teaching[1][:classes].length.should == 2
    teaching[1][:timeBucket].should == "past"
  end

  it "should get correct time buckets for teaching semesters", :if => CampusOracle::Connection.test_data? do
    feed = {}
    MyAcademics::Teaching.new("904715").merge(feed)
    feed.empty?.should be_falsey
    teaching = feed[:teachingSemesters]
    teaching.length.should == 2
    teaching[0][:name].should == "Summer 2014"
    teaching[0][:timeBucket].should == "future"
    teaching[1][:name].should == "Fall 2013"
    teaching[1][:timeBucket].should == "current"
  end

end
