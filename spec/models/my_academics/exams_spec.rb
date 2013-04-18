require "spec_helper"

describe "MyAcademics::Exams" do

  it "should format fake Bearfacts exam data correctly" do
    proxy = BearfactsExamsProxy.new({:user_id => "61889", :fake => true})
    BearfactsExamsProxy.stub(:new).and_return(proxy)

    feed = {}
    MyAcademics::Exams.new("61889").merge(feed)

    Rails.logger.info "feed[:exam_schedule] = #{feed[:exam_schedule].inspect}"
    feed[:exam_schedule].should_not be_nil
  end

end
