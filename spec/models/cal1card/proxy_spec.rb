require 'spec_helper'

describe Cal1card::Proxy do

  let (:fake_oski_proxy) { Cal1card::Proxy.new({user_id: '61889', fake: true}) }
  let (:real_oski_proxy) { Cal1card::Proxy.new({user_id: '61889', fake: false}) }
  let (:cal1card_uri) { URI.parse(Settings.cal1card_proxy.feed_url) }

  context "fetching fake data feed" do
    subject { fake_oski_proxy.get }
    it { should_not be_empty }
  end

  context "checking the fake feed for correct json" do
    subject { fake_oski_proxy.get }
    it {
      subject[:cal1cardStatus].should == 'OK'
      subject[:debit].should == '0.8'
      subject[:mealpoints].should == '359.11'
      subject[:mealpointsPlan].should == 'Resident Meal Plan Points'
    }
  end

  context "proper caching behaviors" do
    it "should write to cache" do
      Rails.cache.should_receive(:write)
      fake_oski_proxy.get
    end
  end

  context "getting real data feed", testext: true do
    subject { real_oski_proxy.get }
    it { should_not be_empty }
    its([:statusCode]) { should eq 200 }
  end

  context "unreachable remote server (connection errors)" do
    before(:each) {
      stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
      Rails.cache.should_not_receive(:write)
    }
    after(:each) { WebMock.reset! }
    subject { real_oski_proxy.get }

    its([:body]) { should eq("An unknown server error occurred") }
    its([:statusCode]) { should eq(503) }
  end

  context "error on remote server (5xx errors)" do
    before(:each) {
      stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_return(status: 506)
      Rails.cache.should_not_receive(:write)
    }
    after(:each) { WebMock.reset! }
    subject { real_oski_proxy.get }

    its([:body]) { should eq("Cal1Card is currently unavailable. Please try again later.") }
    its([:statusCode]) { should eq(506) }
  end

  context "proxy should respect a disabled feature flag" do
    before(:each) {
      Settings.features.stub(:cal1card).and_return(false)
    }
    subject { real_oski_proxy.get }
    it { should eq({}) }
  end

end
