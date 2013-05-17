require "spec_helper"

describe "HotPlate" do

  it "should warm the cache of a user who's visited recently" do
    UserVisit.record "1234"
    UserVisit.record "5678"
    UserCacheWarmer.stub(:do_warm).and_return(nil)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).exactly(2).times

    plate = HotPlate.new
    plate.warm
    plate.total_warmups.should == 2
  end


  it "should not explode if an error gets thrown during the warming" do
    UserVisit.record "1234"
    UserCacheWarmer.stub(:do_warm).and_raise(TypeError)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once

    plate = HotPlate.new
    plate.warm
    plate.total_warmups.should == 0
  end

end
