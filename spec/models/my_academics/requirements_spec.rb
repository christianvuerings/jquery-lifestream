require "spec_helper"

describe "MyAcademics::Requirements" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_profile_proxy = BearfactsProfileProxy.new({:user_id => "61889", :fake => true})
    BearfactsProfileProxy.stub(:new).and_return(oski_profile_proxy)

    feed = {}
    MyAcademics::Requirements.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_requirements = feed[:requirements]
    oski_requirements.length.should == 4

  end

end
