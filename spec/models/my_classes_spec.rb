require "spec_helper"

describe "MyClasses" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas = {
        classes: [{
            id: '1023614',
            emitter: 'bCourses',
            courses: [ { id: 'BIOLOGY:1A:2013-C'}]
        }]
    }
    @fake_sakai = {
        classes: [{
            id: '095d5b02-afde-4186-a668-0b84734b1d5c',
            emitter: 'bSpace',
            courses: [ { id: 'BIOLOGY:1A:2013-C'}]
        }]
    }
    @fake_campus = [{
        id: 'BIOLOGY:1A:2013-C',
        course_code: 'BIOLOGY 1A',
        emitter: 'Campus'
    }]
  end

  it "should contain all my Canvas courses which match enrolled sections" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(true)
    CanvasUserSites.any_instance.stub(:get_feed).and_return(@fake_canvas)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(@fake_campus)
    feed = MyClasses.new(@user_id).get_feed
    my_classes = feed[:classes]
    my_classes.size.should == 2
    my_classes.index{|entry| entry[:emitter] == CanvasProxy::APP_NAME && entry[:id] == '1023614'}.should_not be_nil
    my_classes.index{|entry| entry[:emitter] == CampusUserCoursesProxy::APP_ID && entry[:id] == 'BIOLOGY:1A:2013-C'}.should_not be_nil
  end

  it "should return successfully without Canvas or bSpace access" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.should_not_receive(:new)
    SakaiUserSitesProxy.should_not_receive(:new)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return([])
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should == 0
  end

  it "should return bSpace course sites for the current term" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return(@fake_sakai)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(@fake_campus)
    feed = MyClasses.new(@user_id).get_feed
    my_classes = feed[:classes]
    my_classes.size.should == 2
    my_classes.index{|entry| entry[:emitter] == SakaiProxy::APP_ID && entry[:id] == '095d5b02-afde-4186-a668-0b84734b1d5c'}.should_not be_nil
    my_classes.index{|entry| entry[:emitter] == CampusUserCoursesProxy::APP_ID && entry[:id] == 'BIOLOGY:1A:2013-C'}.should_not be_nil
  end

  it "should return classes in which I am officially enrolled" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(@fake_campus)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "Campus"
      my_class[:course_code].should_not be_nil
    end
  end

  it "should return some classes for only instructors", :if => CampusData.test_data? do
    #Match this with some instructor from populate_campus_h2, like this awful Cog Sci/Bio teacher
    my_classes = MyClasses.new('192517').get_feed
    results = my_classes[:classes].select {|entry| entry[:role] == "Instructor" }
    (results.size >= 2).should be_true
  end
end
