require "spec_helper"

describe "MyCourseSites" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_canvas_proxy = CanvasProxy.new({fake: true})
    @fake_canvas_courses = JSON.parse(@fake_canvas_proxy.courses.body)
  end

  it "should contain all my Canvas courses" do
    Oauth2Data.stub(:get_access_token).and_return("something")
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    my_classes = MyCourseSites.get_feed(@user_id)
    my_classes.size.should == @fake_canvas_courses.size
    my_classes.each do |my_class|
      my_class[:emitter].should == "Canvas"
      my_class[:course_code].should_not == nil
      my_class[:id].instance_of?(String).should == true
    end
  end

  it "should return successfully without Canvas access" do
    Oauth2Data.stub(:get_access_token).and_return(nil)
    CanvasProxy.should_not_receive(:new)
    my_classes = MyCourseSites.get_feed(@user_id)
    my_classes.size.should == 0
  end

end