require "spec_helper"

describe "MyClasses" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas_proxy = CanvasCoursesProxy.new({fake: true})
    @fake_canvas_courses = JSON.parse(@fake_canvas_proxy.courses.body)
    @fake_sakai_proxy = SakaiCategorizedProxy.new({fake: true})
  end

  it "should contain all my Canvas courses" do
    @fake_canvas_courses.size.should be > 0
    Oauth2Data.stub(:get).and_return({"access_token" => "something"})
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(false)
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
    SakaiProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.should_not_receive(:new)
    SakaiProxy.should_not_receive(:new)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should == 0
  end

  it "should return bSpace course sites for the current term" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiCategorizedProxy.stub(:new).and_return(@fake_sakai_proxy)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
      my_class[:course_code].should_not be_nil
      my_class[:id].instance_of?(String).should == true
      my_class[:site_url].should_not be_nil
    end
  end

  it "should return bSpace courses when Canvas service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiCategorizedProxy.stub(:new).and_return(@fake_sakai_proxy)
    CanvasProxy.any_instance.stub(:request).and_return(nil)
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
    end
  end

  it "should return Canvas courses when bSpace service is unavailable" do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.any_instance.stub(:do_get).and_return({status_code: 503})
    my_classes = MyClasses.new(@user_id).get_feed
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "Canvas"
    end
  end

end