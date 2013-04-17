require "spec_helper"

describe "MyAcademics" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_blocks_proxy = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
    BearfactsRegblocksProxy.stub(:new).and_return(oski_blocks_proxy)
    oski_profile_proxy = BearfactsProfileProxy.new({:user_id => "61889", :fake => true})
    BearfactsProfileProxy.stub(:new).and_return(oski_profile_proxy)
    oski_schedule_proxy = BearfactsScheduleProxy.new({:user_id => "61889", :fake => true})
    BearfactsScheduleProxy.stub(:new).and_return(oski_schedule_proxy)

    oski_academics = MyAcademics::Merged.new("61889").get_feed
    oski_academics.empty?.should be_false

    oski_blocks = oski_academics[:regblocks]
    oski_blocks[:active_blocks].empty?.should be_false
    oski_blocks[:active_blocks].each do |block|
      block[:status].should == "Active"
      block[:type].should_not be_nil
    end

    oski_blocks[:inactive_blocks].empty?.should be_false
    oski_blocks[:inactive_blocks].each do |block|
      block[:status].should == "Released"
      block[:type].should_not be_nil
    end

    oski_college = oski_academics[:college_and_level]
    oski_college.should_not be_nil
    oski_college[:college].should == "ENGR"
    oski_college[:standing].should == "Undergraduate"

    oski_requirements = oski_academics[:requirements]
    oski_requirements.length.should == 4

    oski_semesters = oski_academics[:semesters]
    oski_semesters.length.should == 1
    oski_semesters[0][:name].should == "Spring 2013"
    oski_semesters[0][:schedule].length.should == 4

  end

end
