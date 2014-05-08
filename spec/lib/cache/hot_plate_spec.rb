require "spec_helper"

describe "HotPlate" do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @plate = HotPlate.new
  end

  it "should warm the cache of some users who have visited recently" do
    User::Visit.record "1234"
    User::Visit.record "5678"
    Messaging.should_receive(:publish).with('/queues/hot_plate', "1234", {ttl: 86400000, persistent: false}).exactly(1).times
    Messaging.should_receive(:publish).with('/queues/hot_plate', "5678", {ttl: 86400000, persistent: false}).exactly(1).times
    @plate.warm
  end

  it "should not explode if an error gets thrown during the warming" do
    User::Visit.record "1234"
    Cache::UserCacheWarmer.stub(:do_warm).and_raise(TypeError)
    Cache::UserCacheExpiry.should_receive(:notify).once

    @plate.expire_then_complete_warmup "1234"
  end

  it "should process warmup request messages" do
    Cache::UserCacheWarmer.stub(:do_warm).and_return(nil)
    Cache::UserCacheExpiry.should_receive(:notify).with(@random_id)
    HotPlate.should_receive(:increment).exactly(2).times
    Cache::UserCacheWarmer.should_receive(:do_warm).with(@random_id)
    @plate.on_message(@random_id)
  end

end
