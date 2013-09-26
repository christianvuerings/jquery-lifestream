require 'spec_helper'

describe FinancialsProxy do

  let(:live_oski_financials) { FinancialsProxy.new({:user_id => "61889"}).get }
  let(:fake_oski_financials) { FinancialsProxy.new({:user_id => "61889", :fake => true}).get }

  shared_examples "has some minimal oski data" do
    it { subject[:body].should_not be_nil }
    it { subject[:body]["student"].should_not be_nil }
    it { subject[:body]["student"]["summary"].should_not be_nil }
    it { subject[:status_code].should == 200 }
  end

  context "oski live financials", :testext => true do
    subject { live_oski_financials }
    it_behaves_like "has some minimal oski data"
  end

  context "fake oski financials" do
    subject { fake_oski_financials }
    it_behaves_like "has some minimal oski data"
    it { subject[:body]["student"]["summary"]["futureActivity"].should == "222.5" }
  end

  context "unreachable remote server (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_raise(Errno::ECONNREFUSED) }
    after(:each) { WebMock.reset! }
    subject { live_oski_financials }

    it { subject[:body].should eq("Remote server unreachable") }
    it { subject[:status_code].should eq(503) }
  end

  context "errors on remote server" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.financials_proxy.base_url)}.*/).to_return(:status => 403) }
    after(:each) { WebMock.reset! }

    subject { live_oski_financials }
    it { should be_nil }
  end
end
