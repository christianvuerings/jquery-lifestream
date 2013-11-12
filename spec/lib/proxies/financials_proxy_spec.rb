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
    subject { live_oski_financials }
    it_behaves_like "has some minimal oski data"
  end

  context "tammi is missing financials" do
    subject { fake_tammi_financials }
    it { should be_nil }
  end

  context "non-student should not get any financials" do
    subject { non_student_financials }
    it { should be_nil }
  end

  context "fake oski financials" do
    subject { fake_oski_financials }
    it_behaves_like "has some minimal oski data"
    it { subject[:body]["student"]["summary"]["futureActivity"].should == 25.0 }
  end

  context "unreachable remote server (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_raise(Errno::ECONNREFUSED) }
    after(:each) { WebMock.reset! }
    subject { live_oski_financials }

    its([:body]) { should eq("Remote server unreachable") }
    its([:status_code]) { should eq(503) }
  end

  context "errors on remote server" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_return(status: 403) }
    after(:each) { WebMock.reset! }

    subject { live_oski_financials }
    it { should be_nil }
  end
end
