require "spec_helper"

describe "MyClasses" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas_proxy = CanvasProxy.new({fake: true})
    @fake_canvas_courses = JSON.parse(@fake_canvas_proxy.courses.body)
    @fake_sakai_proxy = SakaiProxy.new({fake: true})
  end

  it "should contain all my Canvas courses" do
    @fake_canvas_courses.size.should be > 0
    Oauth2Data.stub(:get).and_return({"access_token" => "something"})
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    SakaiProxy.stub(:access_granted?).and_return(false)
    my_classes = MyClasses.get_feed(@user_id)
    my_classes[:classes].size.should == @fake_canvas_courses.size
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == CanvasProxy::APP_ID
      my_class[:course_code].should_not == nil
      my_class[:id].instance_of?(String).should == true
    end
  end

  it "should return successfully without Canvas or bSpace access" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(false)
    CanvasProxy.should_not_receive(:new)
    SakaiProxy.should_not_receive(:new)
    my_classes = MyClasses.get_feed(@user_id)
    my_classes[:classes].size.should == 0
  end

  it "should return bSpace course sites for the current term" do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiProxy.stub(:new).and_return(@fake_sakai_proxy)
    my_classes = MyClasses.get_feed(@user_id)
    my_classes[:classes].size.should be > 0
    my_classes[:classes].each do |my_class|
      my_class[:emitter].should == "bSpace"
      my_class[:course_code].should_not == nil
      my_class[:id].instance_of?(String).should == true
    end
  end

end