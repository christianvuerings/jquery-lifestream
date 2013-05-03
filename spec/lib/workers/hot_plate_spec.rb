require "spec_helper"

describe "HotPlate" do

  it "should warm the cache of a user who's visited recently" do
    UserVisit.record "1234"
    UserVisit.record "5678"

    warmer = UserCacheWarmer.new
    warmer.stub(:warm).and_return(nil)
    Calcentral::USER_CACHE_WARMER = warmer

    plate = HotPlate.new
    plate.warm

  end
end
