require "spec_helper"

describe "MyAcademics::Exams" do

  it "should format fake Bearfacts exam data correctly" do
    proxy = BearfactsExamsProxy.new({:user_id => "61889", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("61889").merge(feed)

    Rails.logger.info "feed[:exam_schedule] = #{feed[:exam_schedule].inspect}"
    feed[:exam_schedule].should_not be_nil
    feed[:exam_schedule]["Tue May 14"][0][:course_number].should == "Psychology C120"
    feed[:exam_schedule]["Tue May 14"][0][:time].should == "8:00A"
    feed[:exam_schedule]["Tue May 14"][0][:location][:raw_location].should == "390 HEARST MIN"
    feed[:exam_schedule]["Tue May 14"][0][:location]["room_number"].should == "390"
    feed[:exam_schedule]["Tue May 14"][0][:location]["display"].should == "Hearst Memorial Mining Building"
  end

  it "should properly handle a student with an exam in an unparseable room" do
    proxy = BearfactsExamsProxy.new({:user_id => "865826", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("865826").merge(feed)

    Rails.logger.info "feed[:exam_schedule] = #{feed[:exam_schedule].inspect}"
    feed[:exam_schedule].should_not be_nil
    feed[:exam_schedule]["Wed May 15"][0][:location][:raw_location].should == "F295 HAAS"
  end

end
