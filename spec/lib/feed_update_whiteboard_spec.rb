require "spec_helper"

describe "FeedUpdateWhiteboard" do

  before :each do
    @board = FeedUpdateWhiteboard.new
  end

  it "should save the status of a mock UserAPI update event" do
    @board.on_message({:feed => "UserApi", :uid => "1234"})
    saved = Rails.cache.read(FeedUpdateWhiteboard.cache_key("1234"))
    saved["UserApi"].should_not be_nil
  end

  it "should not explode on an empty message" do
    @board.on_message(nil).should be_nil
    @board.on_message({:badkey => false}).should be_nil
  end

  it "should skip processing a message with a unknown class" do
    @board.on_message({:feed => "Object", :uid => "1234"}).should be_nil
  end

end
