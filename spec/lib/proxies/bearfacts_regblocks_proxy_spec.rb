require "spec_helper"

describe "BearfactsRegblocksProxy" do

  it "should get Oski Bear's reg blocks from fake vcr recordings" do
    client = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
    xml = client.get
    xml.should_not be_nil
  end

  it "should fail gracefully on a user whose student_id can't be found" do
    client = BearfactsRegblocksProxy.new({:user_id => "0", :fake => true})
    response = client.get
    response[:body].should == "Lookup of student_id for uid 0 failed, cannot call Bearfacts API"
    response[:status_code].should == 400
  end

  it "should get Oski Bear's reg blocks from a real server", :testext => true, :ignore => true do
    client = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => false})
    xml = client.get
    xml.should_not be_nil
  end

end
