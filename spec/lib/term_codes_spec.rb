require "spec_helper"

describe "TermCodes" do

  it "should convert code and year into nice English" do
    TermCodes.to_english("2013", "B").should == "Spring 2013"
  end

  it "should throw an exception if a bogus term code is supplied" do
    expect{ TermCodes.to_english("1947", "Q")}.to raise_error(ArgumentError)
  end

end
