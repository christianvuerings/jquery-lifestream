require "spec_helper"

describe "MyAcademics::Exams" do

  it "should format fake Bearfacts exam data correctly" do
    proxy = BearfactsExamsProxy.new({:user_id => "61889", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("61889").merge(feed)

    feed[:exam_schedule].should_not be_nil
    feed[:exam_schedule][0][:course_number].should == "Psychology C120"
    feed[:exam_schedule][0][:time].should == "8:00A"
    feed[:exam_schedule][0][:location][:raw_location].should == "390 HEARST MIN"
    feed[:exam_schedule][0][:location]["room_number"].should == "390"
    feed[:exam_schedule][0][:location]["display"].should == "Hearst Memorial Mining Building"
    # Make sure the date epoch matches the expected date.
    Time.at(feed[:exam_schedule][0][:date][:epoch]).to_s.start_with?('2013-05-14').should be_true
    # making sure sorting works in right order
    feed[:exam_schedule][0][:date][:epoch].should < feed[:exam_schedule][1][:date][:epoch]
    feed[:exam_schedule][1][:date][:epoch].should < feed[:exam_schedule][2][:date][:epoch]
  end

  it "should properly handle a student with an exam in an unparseable room" do
    proxy = BearfactsExamsProxy.new({:user_id => "865826", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("865826").merge(feed)

    feed[:exam_schedule].should_not be_nil
    feed[:exam_schedule][0][:location][:raw_location].should == "F295 HAAS"
  end

  it "should not return any exam schedules for exam information not matching current_year and term" do
    CampusData.stub(:current_term).and_return("B")
    CampusData.stub(:current_year).and_return("1984")
    proxy = BearfactsExamsProxy.new({:user_id => "865826", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("865826").merge(feed)

    feed[:exam_schedule].should be_nil
  end

  it "should handle badly formatted BearfactsExamProxy XML responses" do
    proxy = BearfactsExamsProxy.new({:user_id => "865826", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)
    BearfactsExamsProxy.any_instance.stub(:get).and_return({body: 'gobbly gook', status_code: 200})

    feed = {}
    MyAcademics::Exams.new("865826").merge(feed)

    feed[:exam_schedule].should be_nil
  end

  context "failing bearfacts proxy" do
    before(:each) do
      stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      BearfactsProfileProxy.new({:user_id => "212381", :fake => false})
    end
    after(:each) { WebMock.reset! }

    subject do
      MyAcademics::Exams.new("212381").merge(@feed = {})
      @feed
    end

    it { should be_blank }

  end
end
