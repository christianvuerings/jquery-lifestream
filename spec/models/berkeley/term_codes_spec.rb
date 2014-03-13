require "spec_helper"

describe TermCodes do

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

  it 'should convert a friendly term into code and year' do
    term_hash = TermCodes.from_english('Fall 2013')
    term_hash[:term_yr].should == '2013'
    term_hash[:term_cd].should == 'D'
  end

  it 'should convert an unfriendly term into nothing' do
    TermCodes.from_english('Indefinitely').should be_nil
  end

end
