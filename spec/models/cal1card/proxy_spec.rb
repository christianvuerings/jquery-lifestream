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

end
