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
    oski_college[:colleges].size.should == 3
    oski_college[:colleges][0][:college].should == "College of Engineering"
    oski_college[:colleges][0][:major].should == "Economics"
    oski_college[:colleges][1][:major].should == "Rhetoric"
    oski_college[:colleges][2][:major].should == "Business Administration"
    oski_college[:standing].should == "Undergraduate"
  end

  it "should get test-300940's multiple college enrollments" do
    tammi_proxy = BearfactsProfileProxy.new({:user_id => "300940", :fake => true})
    BearfactsProfileProxy.stub(:new).and_return(tammi_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("300940").merge(feed)
    feed.empty?.should be_false

    colleges = feed[:college_and_level][:colleges]
    colleges.size.should == 2
    colleges[0][:college].should == "College of Natural Resources"
    colleges[0][:major].should == "Conservation And Resource Studies"
    colleges[1][:college].should == "College of Environmental Design"
    colleges[1][:major].should == "Landscape Architecture"

  end
end
