require "spec_helper"

describe "MyFinancials" do

  let!(:oski_uid) { "61889"}
  let!(:fake_financials_proxy) { FinancialsProxy.new({:user_id => oski_uid, :fake => false}) }

  context "happy path" do

    before(:each) { FinancialsProxy.stub(:new).and_return(fake_financials_proxy) }

    subject do
      MyFinancials.new(oski_uid).get_feed
    end

    it { should_not be_nil }
    it { subject["student"]["summary"].should_not be_nil }

  end

end
