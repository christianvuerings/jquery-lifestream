require "spec_helper"

describe Cache::FeedUpdateWhiteboard do

  before :each do
    @board = Cache::FeedUpdateWhiteboard.new
  end

  it "should save the status of a mock UserAPI update event" do
    @board.on_message("1234")
    saved = Cache::FeedUpdateWhiteboard.get_whiteboard("1234")
    Cache::LiveUpdatesEnabled.classes.each do |klass|
      expect(saved[klass.name]).to be
    end
  end

  it "should not explode on an empty message" do
    expect(@board.on_message(nil)).to be_nil
  end

end
