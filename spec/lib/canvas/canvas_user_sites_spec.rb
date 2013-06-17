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
    feed[:classes].each do |class_site|
      ['course', 'group'].include?(class_site[:site_type]).should be_true
      class_site[:role].should == 'student'
      class_site[:courses].empty?.should be_false
      class_site[:courses].each do |course_data|
        course_data[:id].blank?.should be_false
      end
    end
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
                course_code: 'BIOLOGY 1A'
            },
            {
                id: 234,
                enrollments: [{type: 'student'}],
                course_code: 'SOCIOL 136'
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
            id: 'BIOLOGY:1A:2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            color_class: "campus-class",
            role: 'Student',
            sections: [
                { ccn: 7366 },
                { ccn: 7309 }
            ]
        }
    ])
    CanvasGroupsProxy.stub(:new).and_return(stub_proxy(:groups, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:classes].length.should == 1
    class_item = feed[:classes][0]
    class_item[:id].should == '123'
    class_courses = class_item[:courses]
    class_courses.length.should == 1
    class_courses[0][:id].should == 'BIOLOGY:1A:2013-C'
    feed[:groups].length.should == 1
    group = feed[:groups][0]
    group[:id].should == '234'
    group[:site_type].should == 'course'
    group[:role].should == 'student'
  end

  it "should put a Canvas Course site without any official enrollment connection into groups" do
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
    feed[:classes].empty?.should be_true
    feed[:groups].length.should == 1
    group = feed[:groups][0]
    group[:id].should == '123'
    group[:site_type].should == 'course'
    group[:role].should == 'student'
  end

  it "should put an instructor's Canvas Course site into groups" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'teacher'}],
                course_code: 'BIOLOGY 1A'
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
            id: 'BIOLOGY:1A:2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            color_class: "campus-class",
            role: 'Instructor',
            sections: [
                { ccn: 7309 }
            ]
        }
    ])
    CanvasGroupsProxy.stub(:new).and_return(stub_proxy(:groups, []))
    model = CanvasUserSites.new(@uid)
    feed = model.get_feed_internal
    feed[:classes].empty?.should be_true
    feed[:groups].length.should == 1
    group = feed[:groups][0]
    group[:id].should == '123'
    group[:site_type].should == 'course'
    group[:role].should == 'teacher'
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
  end

  it "should put suitable course-linked Canvas Group sites into classes" do
    CanvasUserCoursesProxy.stub(:new).and_return(
        stub_proxy(:courses, [
            {
                id: 123,
                enrollments: [{type: 'student'}],
                course_code: 'BIOLOGY 1A'
            },
            {
                id: 234,
                enrollments: [{type: 'student'}],
                course_code: 'SOCIOL 136'
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
            id: 'BIOLOGY:1A:2013-C',
            term_yr: 2013,
            term_cd: 'C',
            dept: 'BIOLOGY',
            catid: '1A',
            course_code: 'BIOLOGY 1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            color_class: "campus-class",
            role: 'Student',
            sections: [
                { ccn: 7309 }
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
    feed[:classes].length.should == 2
    feed[:classes].index { |site|
      site[:id] == '123' &&
          site[:site_type] == 'course'
    }.should_not be_nil
    feed[:classes].index { |site|
      site[:id] == '321' &&
          site[:site_type] == 'group'
    }.should_not be_nil
    feed[:groups].length.should == 2
    feed[:groups].index { |site|
      site[:id] == '432' &&
          site[:site_type] == 'group'
    }.should_not be_nil
  end

end

def stub_proxy(feed_method, stub_body)
  proxy = double()
  response = double()
  response.stub(:status).and_return(200)
  response.stub(:body).and_return(stub_body.to_json)
  proxy.stub(feed_method).and_return(response)
  proxy
end