require "spec_helper"

describe CanvasUserSites do
  before do
    @uid = Settings.canvas_proxy.test_user_id
  end

  it "should return a properly structured feed for a known user" do
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed
    feed.should_not be_nil
    feed[:classes].should_not be_nil
    non_official_classes ||= 0
    feed[:classes].each do |class_site|
      ['course', 'group'].include?(class_site[:site_type]).should be_true
      class_site[:role].should == 'student'
      non_official_classes += 1 if class_site[:courses].empty?
      class_site[:courses].each do |course_data|
        course_data[:id].blank?.should be_false
      end
    end
    non_official_classes.should == 2
    feed[:groups].should_not be_nil
    feed[:groups].each do |group_site|
      ['course', 'group'].include?(group_site[:site_type]).should be_true
      if group_site[:site_type] == 'course'
        group_site[:role].blank?.should be_false
      end
      group_site[:courses].should be_nil
    end
  end

  it "should return a Canvas Course site that matches at least one enrolled section" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'student'}],
                course_code: 'Bio 1A summer',
                name: 'Biology 1A catch-up'
            },
            {
                id: 234,
                enrollments: [{type: 'student'}],
                course_code: 'SOCIOL 13.6. Su',
                name: 'Urban Sociology'
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 123}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 123,
                id: 58685,
                name: 'Some non-campus section',
                sis_section_id: 'Some-odd-thing'
            },
            {
                course_id: 123,
                id: 58686,
                name: '2013-C-7309',
                sis_section_id: 'SEC:2013-C-7309'
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 234}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 234,
                id: 1093164,
                name: '2013-C-136',
                sis_section_id: 'SEC:2013-C-136'
            }
        ])
    )
    CampusUserCoursesProxy.stub_chain(:new, :get_campus_courses).and_return([
        {
            id: 'BIOLOGY-1A-2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            role: 'Student',
            sections: [
                { ccn: '07366' },
                { ccn: '07309' }
            ]
        }
    ])
    CanvasGroupsProxy.stub(:new).and_return(stub_proxy(:groups, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:classes].length.should >= 1
    class_item = feed[:classes].select{|klass| klass[:courses].present?}[0]
    class_item[:id].should == '123'
    class_item[:short_description].should == 'Biology 1A catch-up'
    class_item[:name].should == 'Bio 1A summer'
    class_courses = class_item[:courses]
    class_courses.length.should == 1
    class_courses[0][:id].should == 'BIOLOGY-1A-2013-C'
    unofficial_class_item = feed[:classes].select{|klass| klass[:courses].empty?}[0]
    unofficial_class_item[:id].should == '234'
    unofficial_class_item[:site_type].should == 'course'
    unofficial_class_item[:role].should == 'student'
    unofficial_class_item[:short_description].should == 'Urban Sociology'
    unofficial_class_item[:name].should == 'SOCIOL 13.6. Su'
    feed[:groups].length.should == 0
  end

  it "should put a Canvas Course site without any official enrollment connection into classes" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'student'}]
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 123}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 123,
                id: 58686,
                name: 'not-an-official-section',
                sis_section_id: nil
            }
        ])
    )
    CanvasGroupsProxy.stub(:new).and_return(stub_proxy(:groups, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:groups].empty?.should be_true
    feed[:classes].length.should == 1
    klass = feed[:classes][0]
    klass[:id].should == '123'
    klass[:site_type].should == 'course'
    klass[:role].should == 'student'
  end

  it "should put an instructor's Canvas Course site into classes if it's an official enrollment" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'teacher'}],
                course_code: 'Bio 1A',
                name: 'Biology for surfers'
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 123}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 123,
                id: 58686,
                name: '2013-C-7309',
                sis_section_id: 'SEC:2013-C-7309'
            }
        ])
    )
    CampusUserCoursesProxy.stub_chain(:new, :get_campus_courses).and_return([
        {
            id: 'BIOLOGY-1A-2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            role: 'Instructor',
            sections: [
                { ccn: '07309' }
            ]
        }
    ])
    CanvasGroupsProxy.stub(:new).and_return(stub_proxy(:groups, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:groups].empty?.should be_true
    feed[:classes].length.should == 1
    classes = feed[:classes][0]
    classes[:id].should == '123'
    classes[:site_type].should == 'course'
    classes[:role].should == 'teacher'
    classes[:name].should == 'Bio 1A'
  end

  it "should put a community-style Canvas Group into groups" do
    CanvasGroupsProxy.stub(:new).and_return(
        stub_proxy(:groups, [
            {
                id: 321,
                context_type: 'Account',
                name: 'The Left Banke'
            }
        ])
    )
    CanvasUserCoursesProxy.stub(:new).and_return(stub_proxy(:courses, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:classes].empty?.should be_true
    feed[:groups].length.should == 1
    group = feed[:groups][0]
    group[:id].should == '321'
    group[:site_type].should == 'group'
    group[:name].should == 'The Left Banke'
    group[:site_url].blank?.should be_false
    group[:emitter].should == "bCourses"
  end

  it "should put suitable course-linked Canvas Group sites into classes" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'student'}],
                course_code: 'Bio 1A',
                name: 'Biology for surfers'
            },
            {
                id: 234,
                enrollments: [{type: 'student'}],
                course_code: 'SOCIOL 136',
                name: 'Sociumi'
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 123}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 123,
                id: 58686,
                name: '2013-C-7309',
                sis_section_id: 'SEC:2013-C-7309'
            }
        ])
    )
    CanvasCourseSectionsProxy.stub(:new).with({course_id: 234}).and_return(
        stub_proxy(:sections_list, [
            {
                course_id: 234,
                id: 1093164,
                name: '2013-C-136',
                sis_section_id: 'SEC:2013-C-136'
            }
        ])
    )
    CampusUserCoursesProxy.stub_chain(:new, :get_campus_courses).and_return([
        {
            id: 'BIOLOGY-1A-2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            role: 'Student',
            sections: [
                { ccn: '07309' }
            ]
        }
    ])
    CanvasGroupsProxy.stub(:new).and_return(
        stub_proxy(:groups, [
            {
                id: 432,
                context_type: 'Course',
                course_id: 234,
                name: 'Early guests'
            },
            {
                id: 321,
                context_type: 'Course',
                course_id: 123,
                name: 'Project Group 4'
            }
        ])
    )
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:classes].length.should == 4
    feed[:classes].index { |site|
      # Non-official canvas course
      site[:id] == '234' &&
        site[:site_type] == 'course' &&
        site[:courses].empty?
    }.should_not be_nil
    feed[:classes].index { |site|
      # Official canvas course, wired by offical section to matching canvas section slug
      site[:id] == '123' &&
        site[:site_type] == 'course'
    }.should_not be_nil
    feed[:classes].index { |site|
      # Official canvas group, wired by canvas course association above
      site[:id] == '321' &&
        site[:site_type] == 'group' &&
        site[:source] == 'Bio 1A' &&
        site[:name] == 'Project Group 4'
    }.should_not be_nil
    feed[:classes].index { |site|
      #Group attached to canvas course, not attached to official enrollment, will end up in other
      site[:id] == '432' &&
        site[:site_type] == 'group' &&
        site[:name] == 'Early guests'
    }.should_not be_nil
    feed[:groups].empty?.should be_true

  end

end
