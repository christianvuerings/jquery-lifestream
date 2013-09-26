require 'spec_helper'

describe FinancialsProxy do

  let(:live_oski_financials) { FinancialsProxy.new({:user_id => "61889"}).get }

  context "oski live financials has some data", :testext => true do
    subject { live_oski_financials }
    it { subject[:body].should_not be_nil }
    it { subject[:body]["student"].should_not be_nil }
    it { subject[:body]["student"]["summary"].should_not be_nil }
    it { subject[:status_code].should == 200 }
  end

end
