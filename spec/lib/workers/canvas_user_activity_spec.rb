require "spec_helper"

describe CanvasUserActivityHandler do

  before do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    fake_feed = CanvasUserActivityProxy.new({:fake => true}).user_activity
    @fake_feed = JSON.parse(fake_feed.body)
  end

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end


  it "should be able to process a normal canvas feed" do
    options = {:fake => true, :user_id => @random_id}
    handler = CanvasUserActivityHandler.new(options)
    notifications = handler.get_feed_results
    notifications.instance_of?(Array).should == true
    notifications.size.should == 20
    notifications.each do | notification |
      notification[:id].blank?.should_not == true
      notification[:user_id].should == @random_id
      notification[:date][:epoch].is_a?(Integer).should == true
      notification[:color_class].should == "canvas-class"
      notification[:source].should == "Canvas"
      notification[:emitter].should == "Canvas"
      notification[:type].blank?.should_not == true
    end
    handler.finalize
  end

  it "should be able to ignore malformed entries from the canvas feed" do
    bad_date_entry = { "id" => @random_id, "user_id" => @random_id, "created_at" => "stone-age"}
    @fake_feed << bad_date_entry
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_return(@fake_feed)
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    notifications = handler.get_feed_results
    notifications.instance_of?(Array).should == true
    notifications.size.should == 20
    handler.finalize
  end

  it "should be able to return nils on unexpected worker crashes" do
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_raise(RuntimeError, "crash")
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    notifications = handler.get_feed_results
    notifications.should be_nil
    handler.finalize
  end

  it "should be able to return nils on unexpected processor crashes" do
    CanvasUserActivityProcessor.any_instance.stub(:process).and_raise(RuntimeError, "crash")
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    notifications = handler.get_feed_results
    notifications.should be_nil
    handler.finalize
  end

  it "get_feed should be a non-blocking call" do
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_return {
      sleep(3)
      @fake_feed
    }
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    start_time = Time.now.to_i
    notifications = handler.get_feed
    end_time = Time.now.to_i
    (end_time - start_time).should < 3
    handler.finalize
  end
end