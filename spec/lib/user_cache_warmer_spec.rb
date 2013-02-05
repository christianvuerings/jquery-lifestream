require "spec_helper"

describe UserCacheWarmer do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should warm the cache when told" do
    model_classes = [ UserApi, MyClasses, MyGroups, MyTasks::Merged, MyUpNext ]
    model_classes.each do |klass|
      model = klass.new @user_id
      klass.stub(:new).and_return(model)
      klass.stub(:get_feed).and_return({})
      model.should_receive(:get_feed)
    end

    worker = UserCacheWarmer::WarmingWorker.new
    worker.warm @user_id
  end

end
