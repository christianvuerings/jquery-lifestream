require "spec_helper"

describe "FeedUpdateWhiteboard" do

  it "should save the status of a bogus UserAPI update event" do
    board = FeedUpdateWhiteboard.new
    board.on_message({:feed => "UserApi", :uid => "1234"})

    saved = Rails.cache.read(FeedUpdateWhiteboard.cache_key("1234"))
    p "saved = #{saved}"
    saved["UserApi"].should_not be_nil
  end
end
