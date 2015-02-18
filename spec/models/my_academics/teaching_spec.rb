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
    bio1a = teaching[0][:classes].select {|course| course[:listings].first[:course_code] == 'BIOLOGY 1A'}[0]
    bio1a[:title].should == "General Biology Lecture"
    bio1a[:role].should == "Instructor"

    bio1a[:listings].count.should eq 1
    bio1a[:listings].first[:dept].should eq "BIOLOGY"

    # Redundant fields to keep parity with student semesters feed structure
    expect(bio1a[:courseCatalog]).to eq "1A"
    expect(bio1a[:course_code]).to eq "BIOLOGY 1A"
    expect(bio1a[:course_id]).to eq "biology-1a-2013-D"
    expect(bio1a[:dept]).to eq "BIOLOGY"
    expect(bio1a[:dept_desc]).to eq "Biology"

    bio1a[:scheduledSectionCount].should eq 3
    bio1a[:scheduledSections].should include({format: 'lecture', count: 1})
    bio1a[:scheduledSections].should include({format: 'discussion', count: 2})

    bio1a[:sections].length.should eq 3
    bio1a[:sections][0][:is_primary_section].should be_truthy
    bio1a[:sections][1][:is_primary_section].should be_falsey
    bio1a[:sections][2][:is_primary_section].should be_falsey
    bio1a[:url].should == '/academics/teaching-semester/fall-2013/class/biology-1a'

    cogsci = teaching[0][:classes].select {|course| course[:listings].first[:course_code] == 'COG SCI C147'}[0]
    cogsci.empty?.should be_falsey
    cogsci[:title].should == "Language Disorders"
    cogsci[:url].should == '/academics/teaching-semester/fall-2013/class/cog_sci-c147'

    cogsci[:listings].first[:dept].should == "COG SCI"

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

  context 'cross-listed courses', if: CampusOracle::Connection.test_data? do
    include_context 'instructor for crosslisted courses'

    subject do
      feed = {}
      MyAcademics::Teaching.new(instructor_id).merge feed
      feed[:teachingSemesters][0][:classes]
    end

    it_should_behave_like 'a feed including crosslisted courses'
  end

end
