require "spec_helper"

describe "HotPlate" do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @plate = HotPlate.new
  end

  it "should warm the cache of a user who's visited recently" do
    UserVisit.record "1234"
    UserVisit.record "5678"
    UserCacheWarmer.stub(:do_warm).and_return(nil)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).exactly(2).times

    @plate.warm
  end


  it "should not explode if an error gets thrown during the warming" do
    UserVisit.record "1234"
    UserCacheWarmer.stub(:do_warm).and_raise(TypeError)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once

    @plate.warm
  end

  it "should delegate a warmup request to the messaging system" do
    Calcentral::Messaging.should_receive(:publish).with('/queues/warmup_request', @random_id).exactly(1).times
    HotPlate.warmup_request(@random_id).should == true
  end

  it "should rate-limit warmup requests" do
    Calcentral::Messaging.should_receive(:publish).with('/queues/warmup_request', @random_id).exactly(1).times
    HotPlate.warmup_request(@random_id).should == true
    HotPlate.warmup_request(@random_id).should == true
    HotPlate.warmup_request(@random_id).should == true
  end

  it "should process warmup request messages" do
    Calcentral::MERGED_FEEDS_EXPIRATION.should_receive(:notify).with(@random_id)
    UserCacheWarmer.should_receive(:do_warm).with(@random_id)
    @plate.on_message(@random_id)
  end

end
