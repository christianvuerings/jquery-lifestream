require "spec_helper"

describe "MyClasses" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas_proxy = CanvasUserCoursesProxy.new({fake: true})
    @fake_canvas_courses = JSON.parse(@fake_canvas_proxy.courses.body)
    @fake_sakai_proxy = SakaiUserSitesProxy.new({fake: true})
  end

  it "should contain all my Canvas courses" do
    @fake_canvas_courses.size.should be > 0
    Oauth2Data.stub(:get).and_return({"access_token" => "something"})
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should == @fake_canvas_courses.size
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == CanvasProxy::APP_ID
      my_class[:course_code].should_not be_nil
      my_class[:id].instance_of?(String).should == true
      my_class[:site_url].should_not be_nil
    end
  end

  it "should return successfully without Canvas or bSpace access" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.should_not_receive(:new)
    SakaiUserSitesProxy.should_not_receive(:new)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should == 0
  end

  it "should return bSpace course sites for the current term" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_proxy)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0 if SakaiData.test_data?
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
      my_class[:course_code].should_not be_nil
      my_class[:id].instance_of?(String).should == true
      my_class[:site_url].should_not be_nil
    end
  end

  it "should return bSpace courses when Canvas returns bad responses" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_proxy)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    response = OpenStruct.new({body: 'derp derp', status: 200})
    CanvasUserCoursesProxy.any_instance.stub(:courses).and_return(response)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0 if SakaiData.test_data?
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
    end
  end

  it "should return bSpace courses when Canvas service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_proxy)
    CanvasProxy.any_instance.stub(:request).and_return(nil)
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0 if SakaiData.test_data?
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
    end
  end

  it "should return Canvas courses when bSpace service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return({status_code: 503})
    CampusUserCoursesProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "Canvas"
    end
  end

  it "should return classes in which I officially teach or am enrolled" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiUserSitesProxy.stub(:access_granted?).and_return(false)
    CampusUserCoursesProxy.any_instance.stub(:get_campus_courses).and_return(
        [{id: "COG SCI:C102:2013-B",
          site_url:
              "http://osoc.berkeley.edu/OSOC/osoc?p_term=SP&x=0&p_classif=--+Choose+a+Course+Classification+--&p_deptname=--+Choose+a+Department+Name+--&p_presuf=--+Choose+a+Course+Prefix%2fSuffix+--&y=0&p_course=C102&p_dept=COG+SCI",
          course_code: "COG SCI C102",
          emitter: "Campus",
          name: "Scientific Approaches to Consciousness",
          color_class: "campus-class",
          courses:
              [{:term_yr=>"2013", :term_cd=>"B", :dept=>"COG SCI", :catid=>"C102"}],
          role: "Student"}]
    )
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "Campus"
      my_class[:course_code].should_not be_nil
    end
  end
end