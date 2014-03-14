require "spec_helper"

describe Cache::FeedUpdateWhiteboard do

  before :each do
    @board = Cache::FeedUpdateWhiteboard.new
  end

  it "should save the status of a mock UserAPI update event" do
    @board.on_message("1234")
    saved = Cache::FeedUpdateWhiteboard.get_whiteboard("1234")
    saved["UserApi"].should_not be_nil
  end

  it "should not explode on an empty message" do
    @board.on_message(nil).should be_nil
  end

end
