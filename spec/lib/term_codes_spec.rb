require "spec_helper"

describe "TermCodes" do

  it "should convert code and year into nice English" do
    TermCodes.to_english("2013", "B").should == "Spring 2013"
  end

  it "should throw an exception if bogus inputs are supplied" do
    expect{ TermCodes.to_english("1947", "Q")}.to raise_error(ArgumentError)
    expect{ TermCodes.to_code("Hiver")}.to raise_error(ArgumentError)
  end

  it "should convert a name into codes" do
    TermCodes.to_code("Spring").should == "B"
    TermCodes.to_code("Summer").should == "C"
    TermCodes.to_code("Fall").should == "D"
  end

end
