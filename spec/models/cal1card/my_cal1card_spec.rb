require "spec_helper"

describe Cal1card::MyCal1card do

  let!(:oski_uid) { "61889" }
  let!(:fake_proxy) { Cal1card::Proxy.new({user_id: oski_uid, fake: true}) }
  before(:each) { Cal1card::Proxy.stub(:new).and_return(fake_proxy) }

  context "happy path" do
    subject { Cal1card::MyCal1card.new(oski_uid).get_feed }
    it {
      should_not be_nil
      subject[:cal1cardStatus].should_not be_nil
    }
  end

  context "it should not explode on a proxy error state" do
    before(:each) { fake_proxy.stub(:get).and_return(
      {
        body: "an error message",
        statusCode: 500
      }
    ) }
    subject { Cal1card::MyCal1card.new(oski_uid).get_feed }
    its([:body]) { should == "an error message" }
    its([:statusCode]) { should == 500 }
  end

  context "it should not explode on a null proxy response" do
    before(:each) { fake_proxy.stub(:get).and_return(nil) }
    subject { Cal1card::MyCal1card.new(oski_uid).get_feed }
    it { subject.length.should == 2 }
  end

  context "it should respect a disabled feature flag" do
    before(:each) { Settings.features.stub(:cal1card).and_return(false) }
    subject { Cal1card::MyCal1card.new(oski_uid).get_feed }
    it { subject.length.should == 2 }
  end

end
