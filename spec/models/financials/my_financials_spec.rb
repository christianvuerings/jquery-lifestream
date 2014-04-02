require "spec_helper"

describe Financials::MyFinancials do

  let!(:oski_uid) { "61889" }
  let!(:fake_financials_proxy) { Financials::Proxy.new({user_id: oski_uid, fake: true}) }
  before(:each) { Financials::Proxy.stub(:new).and_return(fake_financials_proxy) }

  context "happy path" do
    subject { Financials::MyFinancials.new(oski_uid).get_feed }
    it { should_not be_nil }
    its(["summary"]) { should_not be_nil }
    its(["current_term"]) { should == Settings.sakai_proxy.current_terms.first }
    its(["apiVersion"]) { should == "1.0.6" }
  end

  context "it should not explode on a proxy error state" do
    before(:each) { fake_financials_proxy.stub(:get).and_return(
      {
        body: "an error message",
        status_code: 500
      }
    ) }
    subject { Financials::MyFinancials.new(oski_uid).get_feed }
    it { subject.length.should == 4 }
    its([:body]) { should == "an error message"}
    its([:status_code]) { should == 500 }
  end

  context "it should not explode on a null proxy response" do
    before(:each) { fake_financials_proxy.stub(:get).and_return(nil) }
    subject { Financials::MyFinancials.new(oski_uid).get_feed }
    it { subject.length.should == 2 }
  end

end
