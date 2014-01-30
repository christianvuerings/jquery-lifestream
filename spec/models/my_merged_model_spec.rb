require "spec_helper"

describe "MyMergedModel" do

  before(:each) do
    @random_uid = rand(999999).to_s
  end

  context "proper cache handling" do
    it "should cache the feed" do
      MyMergedModel.should_receive(:fetch_from_cache).with(@random_uid, boolean())
      MyMergedModel.new(@random_uid).get_feed
    end
  end

end
