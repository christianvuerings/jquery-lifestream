require "spec_helper"

describe Berkeley::Colleges do

  it "should look up Grad Div" do
    Berkeley::Colleges.get("grad div").should == "Graduate School"
    Berkeley::Colleges.get("engr").should == "College of Engineering"
  end

  it "should return the abbreviation on a nonexistent college abbv" do
    Berkeley::Colleges.get("Zazzle zotz").should == "Zazzle zotz"
  end

end
