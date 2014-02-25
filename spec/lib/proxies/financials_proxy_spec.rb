require 'spec_helper'

describe FinancialsProxy do

  let(:live_oski_financials) { FinancialsProxy.new({user_id: "61889"}).get }
  let(:fake_tammi_financials) { FinancialsProxy.new({user_id: "300940", fake: true}).get }
  let(:fake_oski_financials) { FinancialsProxy.new({user_id: "61889", fake: true}).get }
  let(:non_student_financials) { FinancialsProxy.new({user_id: "212377"}).get }

  shared_examples "has some minimal oski data" do
    its([:body]) { should_not be_nil }
    its([:status_code]) { should == 200 }
    it { subject[:body]["student"].should_not be_nil }
    it { subject[:body]["student"]["summary"].should_not be_nil }
    it { subject[:body]["student"]["summary"]["accountBalance"].is_a?(Numeric).should be_true }
    it { subject[:body]["student"]["summary"]["minimumAmountDue"].is_a?(Numeric).should be_true }
    it { Date.parse(subject[:body]["student"]["summary"]["minimumAmountDueDate"]).is_a?(Date).should be_true }
    it { (subject[:body]["student"]["summary"]["isOnDPP"].is_a?(TrueClass) ||
        subject[:body]["student"]["summary"]["isOnDPP"].is_a?(FalseClass)
    ).should be_true }
  end

  context "oski live financials", testext: true do
    before { Rails.cache.should_receive(:write) }
    subject { live_oski_financials }
    it_behaves_like "has some minimal oski data"
  end

  context "tammi is missing financials" do
    before { Rails.cache.should_receive(:write) }
    subject { fake_tammi_financials }
    its([:body]) { should eq("My Finances did not receive any CARS data for your account. If you are a current or recent student, and you feel that you've received this message in error, please try again later. If you continue to see this error, please use the feedback link below to tell us about the problem.") }
    its([:status_code]) { should eq(404) }
  end

  context "non-student should not get any financials" do
    before { Rails.cache.should_receive(:write) }
    subject { non_student_financials }
    its([:body]) { should eq("CalCentral's My Finances tab is only available for current or recent UC Berkeley students. If you are seeing this message, it is because CalCentral did not receive any CARS data for your account. If you believe that you have received this message in error, please use the Feedback link below to tell us about the problem.")}
    its([:status_code]) { should eq(400) }
  end

  context "fake oski financials" do
    before { Rails.cache.should_receive(:write) }
    subject { fake_oski_financials }
    it_behaves_like "has some minimal oski data"
    it { subject[:body]["student"]["summary"]["futureActivity"].should == 25.0 }
  end

  context "unreachable remote server (5xx errors)" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_raise(Errno::ECONNREFUSED)
      Rails.cache.should_not_receive(:write)
    }
    after(:each) { WebMock.reset! }
    subject { live_oski_financials }

    its([:body]) { should eq("My Finances is currently unavailable. Please try again later.") }
    its([:status_code]) { should eq(503) }
  end

  context "errors on remote server" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_return(status: 403)
      Rails.cache.should_not_receive(:write)
    }
    after(:each) { WebMock.reset! }
    subject { live_oski_financials }
    its([:body]) { should eq("My Finances is currently unavailable. Please try again later.") }
    its([:status_code]) { should eq(403) }
  end
end
