require "spec_helper"

describe Berkeley::TermCodes do

  it "should convert code and year into nice English" do
    Berkeley::TermCodes.to_english("2013", "B").should == "Spring 2013"
  end

  it "should throw an exception if bogus inputs are supplied" do
    expect{ Berkeley::TermCodes.to_english("1947", "Q")}.to raise_error(ArgumentError)
    expect{ Berkeley::TermCodes.to_code("Hiver")}.to raise_error(ArgumentError)
  end

  it "should convert a name into codes" do
    Berkeley::TermCodes.to_code("Spring").should == "B"
    Berkeley::TermCodes.to_code("Summer").should == "C"
    Berkeley::TermCodes.to_code("Fall").should == "D"
  end

  it 'should convert a friendly term into code and year' do
    term_hash = Berkeley::TermCodes.from_english('Fall 2013')
    term_hash[:term_yr].should == '2013'
    term_hash[:term_cd].should == 'D'
  end

  it 'should convert an unfriendly term into nothing' do
    Berkeley::TermCodes.from_english('Indefinitely').should be_nil
  end

  it 'converts a slug into code and year' do
    term_hash = Berkeley::TermCodes.from_slug('fall-2013')
    term_hash[:term_yr].should == '2013'
    term_hash[:term_cd].should == 'D'
  end

end
