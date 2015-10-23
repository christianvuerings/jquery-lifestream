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

  describe '#courses_list_from_ccns' do
    # Lock down to a known set of sections, either in the test DB or in real campus data.
    let(:term) {
      CampusOracle::Connection.test_data? ?  {yr: '2013', cd: 'D'} : {yr: '2013', cd: 'B'}
    }
    let(:good_ccns) { ['07309', '07366', '16171'] }
    let(:bad_ccns) { ['919191'] }
    subject do
      MyAcademics::Teaching.new(random_id).courses_list_from_ccns(term[:yr], term[:cd], (good_ccns + bad_ccns))
    end
    it 'formats section information for known CCNs' do
      expect(subject.length).to eq 1
      classes_list = subject[0][:classes]
      expect(classes_list.length).to eq 2
      bio_class = classes_list[0]
      expect(bio_class[:course_code]).to eq 'BIOLOGY 1A'
      expect(bio_class[:sections].first[:courseCode]).to eq 'BIOLOGY 1A'
      expect(bio_class[:dept]).to eq 'BIOLOGY'
      sections = bio_class[:sections]
      expect(sections.length).to eq 2
      expect(sections[0][:ccn].to_i).to eq 7309
      expect(sections[0][:section_label]).to eq 'LEC 003'
      expect(sections[0][:is_primary_section]).to be_truthy
      expect(sections[1][:ccn].to_i).to eq 7366
      expect(sections[1][:is_primary_section]).to be_falsey
      cog_sci_class = classes_list[1]
      sections = cog_sci_class[:sections]
      expect(sections.length).to eq 1
      expect(sections[0][:ccn].to_i).to eq 16171
    end
  end

end
