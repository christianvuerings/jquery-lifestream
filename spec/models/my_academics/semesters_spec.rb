require "spec_helper"

describe "MyAcademics::Semesters" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_schedule_proxy = BearfactsScheduleProxy.new({:user_id => "61889", :fake => true})
    BearfactsScheduleProxy.stub(:new).and_return(oski_schedule_proxy)

    feed = {}
    MyAcademics::Semesters.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_semesters = feed[:semesters]
    oski_semesters.length.should == 1
    oski_semesters[0][:name].should == "Spring 2013"
    oski_semesters[0][:schedule].length.should == 4
    oski_semesters[0][:schedule][0][:schedule].should == "TuTh 12:30P-2:00P"
  end

end
