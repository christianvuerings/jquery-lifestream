require 'spec_helper'

describe Cal1card::Proxy do

  let (:fake_oski_proxy) { Cal1card::Proxy.new({user_id: '61889', fake: true}) }

  context "fetching fake data feed" do
    subject { fake_oski_proxy.get }
    its([:body]) { should_not be_empty }
  end

  context "checking the fake feed for correct json" do
    subject { JSON.parse(fake_oski_proxy.get[:body]) }
    it {
      subject["cal1card"]["cal1cardStatus"].should == 'OK'
      subject["cal1card"]["debit"].should == '0.8'
      subject["cal1card"]["mealpoints"].should == '359.11'
      subject["cal1card"]["mealpointsPlan"].should == 'Resident Meal Plan Points'
    }
  end

  context "proper caching behaviors" do
    it "should write to cache" do
      Rails.cache.should_receive(:write)
      fake_oski_proxy.get
    end
  end

end
