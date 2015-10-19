describe CampusOracle::UserCourses::All do

  it 'should be accessible if non-null user' do
    CampusOracle::UserCourses::Base.access_granted?(nil).should be_falsey
    CampusOracle::UserCourses::Base.access_granted?('211159').should be_truthy
    client = CampusOracle::UserCourses::All.new({user_id: '211159'})
    client.get_all_campus_courses.should_not be_nil
  end

  it 'should return pre-populated test enrollments for all semesters', :if => CampusOracle::Connection.test_data? do
    Settings.terms.stub(:oldest).and_return(nil)
    client = CampusOracle::UserCourses::All.new({user_id: '300939'})
    courses = client.get_all_campus_courses
    expect(courses.length).to eq 4
    courses.empty?.should be_falsey
    courses["2012-B"].length.should == 2
    courses["2013-D"].length.should == 2
    courses["2013-D"].each do |course|
      course[:id].blank?.should be_falsey
      course[:slug].blank?.should be_falsey
      course[:emitter].should == 'Campus'
      course[:name].blank?.should be_falsey
      expect(course[:courseCodeSection]).to be_blank
      expect(course[:cred_cd]).to be_blank
      expect(course[:pnp_flag]).to be_blank
      expect(course[:units]).to be_blank
      ['Student', 'Instructor'].include?(course[:role]).should be_truthy
      sections = course[:sections]
      sections.length.should be > 0
      sections.each do |section|
        if section[:ccn] == "16171"
          section[:instruction_format].blank?.should be_falsey
          section[:section_number].blank?.should be_falsey
          section[:is_primary_section].should be_truthy
          section[:grade].should be_present
          section.should be_has_key(:cred_cd)
          section[:pnp_flag].should eq 'N '
          section[:units].should eq 3
          section[:instructors].length.should == 1
          section[:instructors][0][:name].present?.should be_truthy
          section[:schedules][0][:schedule].should == "TuTh 2:00P-3:30P"
          section[:schedules][0][:buildingName].should == "WHEELER"
        end
        if section[:ccn] == '7366'
          section[:is_primary_section].should be_falsey
          section[:grade].should be_nil
        end
      end
    end
  end

  context 'with constrained semester range', :if => CampusOracle::Connection.test_data? do
    before { allow(Settings.terms).to receive(:oldest).and_return 'fall-2013'}
    subject { CampusOracle::UserCourses::All.new({user_id: '300939'}).get_all_campus_courses }
    its(:length) {should eq 3}
  end

  it 'includes nested sections for instructors', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::All.new({user_id: '238382'})
    courses = client.get_all_campus_courses
    sections = courses['2013-D'].select {|c| c[:dept] == 'BIOLOGY' && c[:catid] == '1A'}.first[:sections]
    expect(sections.size).to eq 3
    # One primary and two nested secondaries.
    expect(sections.collect{|s| s[:ccn]}).to eq ['07309', '07366', '07372']
  end

  it 'does not duplicate nested sections for instructors', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::All.new({user_id: '904715'})
    courses = client.get_all_campus_courses
    sections = courses['2013-D'].select {|c| c[:dept] == 'BIOLOGY' && c[:catid] == '1A'}.first[:sections]
    expect(sections.size).to eq 3
    # One primary and one secondary, plus one nested secondaries.
    expect(sections.collect{|s| s[:ccn]}).to eq ['07309', '07366', '07372']
  end

  it 'includes cross-listing data for instructors', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::All.new({user_id: '212388'})
    courses = client.get_all_campus_courses['2013-D']
    crosslisteds = courses.select {|c| c[:name] == 'Introduction to the Study of Buddhism'}
    expect(crosslisteds.size).to eq 2
    expect(crosslisteds[0][:sections][0][:cross_listing_hash]).to be_present
    expect(crosslisteds[0][:sections][0][:cross_listing_hash]).to eq crosslisteds[1][:sections][0][:cross_listing_hash]
  end

  it 'removes duplicate sections and instructors', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::All.new({user_id: '322588'})
    courses = client.get_all_campus_courses['2013-D']
    expect(courses[0][:sections].count).to eq 1
    expect(courses[0][:sections][0][:instructors].count).to eq 1
  end

  it 'should find waitlisted status in test enrollments', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::All.new({user_id: '300939'})
    courses = client.get_all_campus_courses
    courses["2014-C"].length.should == 1
    course_primary = courses["2014-C"][0][:sections][0]
    course_primary[:waitlistPosition].should == 42
    course_primary[:enroll_limit].should == 5000
    course_primary[:waitlistPosition].to_s.should == '42'
    course_primary[:enroll_limit].to_s.should == '5000'
  end

end
