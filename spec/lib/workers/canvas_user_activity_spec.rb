require "spec_helper"

describe "CanvasUserActivityHandler" do

  before do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    fake_feed = CanvasUserActivityProxy.new({:fake => true}).user_activity
    @fake_feed = JSON.parse(fake_feed.body)
    @fake_canvas_proxy = CanvasCoursesProxy.new({fake: true})
  end

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  it "should be able to process a normal canvas feed" do
    options = {:fake => true, :user_id => @random_id}
    handler = CanvasUserActivityHandler.new(options)
    activities = handler.get_feed_results
    activities.instance_of?(Array).should == true
    # Activities contains 20 items but 2 need to be filtered out
    activities.size.should == 18
    activities.each do | activity |
      activity[:id].blank?.should_not == true
      activity[:user_id].should == @random_id
      activity[:date][:epoch].is_a?(Integer).should == true
      activity[:color_class].should == "canvas-class"
      activity[:source].blank?.should_not be_true
      activity[:emitter].should == "Canvas"
      activity[:type].blank?.should_not == true
    end
  end

  # Cache stores are only enabled on testext
  it "should be able to work with warmed MyClassses entries", :testext => true do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasCoursesProxy.stub(:new).and_return(@fake_canvas_proxy)
    options = {:fake => true, :user_id => @random_id}
    handler = CanvasUserActivityHandler.new(options)
    activities = handler.get_feed_results
    activities.instance_of?(Array).should == true
    activities.size.should == 18
    interesting_result = activities.select { |entry| entry[:source] == "EE 20N"}
    interesting_result.size.should_not == 0
  end

  it "should be able to ignore malformed entries from the canvas feed" do
    bad_date_entry = { "id" => @random_id, "user_id" => @random_id, "created_at" => "stone-age"}
    @fake_feed << bad_date_entry
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_return(@fake_feed)
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    activities = handler.get_feed_results
    activities.instance_of?(Array).should == true
    activities.size.should == 18
  end


  it "should sometimes have score and instructor message appended to the summary field" do
    # Search for a particular entry in the cassette and make sure it's appended to properly
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_return(@fake_feed)
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    activities = handler.get_feed_results
    activity = activities.select {|entry| entry[:id] == "canvas_40544495"}.first
    activity[:summary].should eq("Please write more neatly next time. 87 out of 100 - Good work!")
  end

  it "should strip system generated 'click here' URLs from the summary field" do
    # But should not over-strip by removing instructor-added 'click here' URLs
    CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_return(@fake_feed)
    handler = CanvasUserActivityHandler.new({:user_id => @random_id})
    activities = handler.get_feed_results

    activity = activities.select {|entry| entry[:id] == "canvas_43225861"}.first
    activity[:summary].should eq("First, some instructor-written text. Click here to view the assignment: https://ucberkeley.instructure.com/courses/832071/assignments/3043635 A new assignment has been created for your course, Biology for Poets Report to STC due: Apr 1 at 11:59pm")

    activity = activities.select {|entry| entry[:id] == "canvas_43395837"}.first
    activity[:summary].should eq("First, some instructor-added text. You can view the submission here: http://example.com?p=123 Oski Bear has just turned in a late submission for Tibullus paper in the course Biology for Poets")
  end

  describe "CanvasUserActivityFailures", :suppress_celluloid_logger => true do

    before :all do
      @original_logger = Celluloid.logger
      Celluloid.logger = nil
    end

    after :all do
      Celluloid.logger = @original_logger
    end

    it "should be able to return nils on unexpected worker crashes" do
      CanvasUserActivityWorker.any_instance.stub(:fetch_user_activity).and_raise(RuntimeError, "crash")
      handler = CanvasUserActivityHandler.new({:user_id => @random_id})
      activities = handler.get_feed_results
      activities.should be_nil
    end

    it("should be able to return nils on unexpected processor crashes", :suppress_celluloid_logger => true) do
      CanvasUserActivityProcessor.any_instance.stub(:process_feed).and_raise(RuntimeError, "crash")
      handler = CanvasUserActivityHandler.new({:user_id => @random_id})
      activities = handler.get_feed_results
      activities.should be_nil
    end

  end
end
