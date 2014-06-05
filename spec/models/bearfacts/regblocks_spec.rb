require "spec_helper"

describe Bearfacts::Regblocks do

  it "should get Oski Bear's reg blocks from fake vcr recordings" do
    client = Bearfacts::Regblocks.new({:user_id => "61889", :fake => true})
    response = client.get
    response.should_not be_nil
    response[:xml_doc].should be_present
  end

  it "should fail gracefully on a user whose student_id can't be found" do
    client = Bearfacts::Regblocks.new({:user_id => "0", :fake => true})
    response = client.get
    response[:noStudentId].should be_true
  end

  it "should get Oski Bear's reg blocks from a real server", :testext => true do
    client = Bearfacts::Regblocks.new({:user_id => "61889", :fake => false})
    response = client.get
    response.should_not be_nil
  end

end
