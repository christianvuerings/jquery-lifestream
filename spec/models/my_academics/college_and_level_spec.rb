require "spec_helper"

describe "MyAcademics::CollegeAndLevel" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_profile_proxy = BearfactsProfileProxy.new({:user_id => "61889", :fake => true})
    BearfactsProfileProxy.stub(:new).and_return(oski_profile_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_college = feed[:college_and_level]
    oski_college.should_not be_nil
    oski_college[:college].should == "ENGR"
    oski_college[:standing].should == "Undergraduate"
    oski_college[:major].should == "Economics, Rhetoric, Business Admin"
  end

end
