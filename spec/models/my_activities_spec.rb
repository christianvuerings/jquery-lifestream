require "spec_helper"

describe "MyActivities" do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_sakai_user_sites = SakaiUserSitesProxy.new(fake: true)
  end

  it "should get properly formatted Sakai announcements when Canvas is not available", :if => SakaiData.test_data? do
    CanvasProxy.stub(:access_granted?).and_return(false)
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(@fake_sakai_user_sites)
    my_activities = MyActivities.new(@user_id).get_feed
    my_activities[:activities].empty?.should be_false
    my_activities[:activities].each do |act|
      act[:emitter].should == 'bSpace'
    end
  end

  # TODO Faking the Canvas activity proxy does not work yet...
  #it "should get properly formatted Canvas activities when bSpace is not available" do
  #  CanvasProxy.stub(:access_granted?).and_return(true)
  #  CanvasUserActivityProxy.stub(:new).and_return(CanvasUserActivityProxy.new({fake: true}))
  #  SakaiProxy.stub(:access_granted?).and_return(true)
  #  SakaiUserSitesProxy.any_instance.stub(:get_categorized_sites).and_return({})
  #  my_activities = MyActivities.new(@user_id).get_feed
  #  my_activities[:activities].empty?.should be_false
  #  my_activities[:activities].each do |act|
  #    act[:emitter].should == 'Canvas'
  #  end
  #end

end