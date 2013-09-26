require "spec_helper"

describe "MyFinancials" do

  let!(:oski_uid) { "61889" }
  let!(:fake_financials_proxy) { FinancialsProxy.new({:user_id => oski_uid, :fake => false}) }
  before(:each) { FinancialsProxy.stub(:new).and_return(fake_financials_proxy) }

  shared_examples "blank feed" do
    it { subject.should be_blank }
  end

  context "happy path" do
    subject { MyFinancials.new(oski_uid).get_feed }
    it { subject.should_not be_nil }
    it { subject["summary"].should_not be_nil }
  end

  context "it should not explode on a proxy error state" do
    before(:each) { fake_financials_proxy.stub(:get).and_return(
      {
        :body => "an error message",
        :status_code => 500
      }
    ) }
    subject { MyFinancials.new(oski_uid).get_feed }
    it_behaves_like "blank feed"
  end

  context "it should not explode on a null proxy response" do
    before(:each) { fake_financials_proxy.stub(:get).and_return(nil) }
    subject { MyFinancials.new(oski_uid).get_feed }
    it_behaves_like "blank feed"
  end

end
