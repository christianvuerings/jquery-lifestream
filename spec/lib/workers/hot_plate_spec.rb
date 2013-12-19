require "spec_helper"

describe "HotPlate" do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @plate = HotPlate.new
  end

  it "should warm the cache of some users who have visited recently" do
    UserVisit.record "1234"
    UserVisit.record "5678"
    Calcentral::Messaging.should_receive(:publish).with('/queues/hot_plate', "1234", {ttl: 86400000, persistent: false}).exactly(1).times
    Calcentral::Messaging.should_receive(:publish).with('/queues/hot_plate', "5678", {ttl: 86400000, persistent: false}).exactly(1).times
    @plate.warm
  end

  it "should not explode if an error gets thrown during the warming" do
    UserVisit.record "1234"
    UserCacheWarmer.stub(:do_warm).and_raise(TypeError)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once

    @plate.expire_then_complete_warmup "1234"
  end

  it "should process warmup request messages" do
    UserCacheWarmer.stub(:do_warm).and_return(nil)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).with(@random_id)
    HotPlate.should_receive(:increment).exactly(2).times
    UserCacheWarmer.should_receive(:do_warm).with(@random_id)
    @plate.on_message(@random_id)
  end

end
