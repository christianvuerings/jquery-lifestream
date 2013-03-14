require "spec_helper"

describe "BearfactsRegblocksProxy" do

  it "should get Oski Bear's reg blocks from fake vcr recordings" do
    client = BearfactsRegblocksProxy.new({:user_id => "11667051", :fake => true})
    xml = client.get_blocks
    xml.should_not be_nil
  end

  it "should get Oski Bear's reg blocks from a real server", :testext => true do
    client = BearfactsRegblocksProxy.new({:user_id => "11667051", :fake => false})
    xml = client.get_blocks
    xml.should_not be_nil
  end

end
