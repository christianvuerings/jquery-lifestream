require "spec_helper"

describe "Colleges" do

  it "should look up Grad Div" do
    Colleges.get("grad div").should == "Graduate School"
    Colleges.get("engr").should == "College of Engineering"
  end

  it "should return the abbreviation on a nonexistent college abbv" do
    Colleges.get("Zazzle zotz").should == "Zazzle zotz"
  end

end
