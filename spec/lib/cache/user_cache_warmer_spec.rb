require "spec_helper"

describe Cache::UserCacheWarmer do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should warm the cache when told" do
    model_classes = Cache::LiveUpdatesEnabled.classes
    model_classes.each do |klass|
      model = klass.new @user_id
      klass.stub(:new).and_return(model)
      klass.stub(:get_feed).and_return({})
      model.should_receive(:warm_cache).once
    end

    Cache::UserCacheWarmer.do_warm @user_id
  end

end
