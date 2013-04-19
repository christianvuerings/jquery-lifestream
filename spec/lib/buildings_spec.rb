require "spec_helper"

describe "Buildings" do

  it "should look up Hearst Mining" do
    Buildings.get("hearst min")["display"].should == "Hearst Memorial Mining Building"
  end

  it "should look up Lothlorien with a room number" do
    Buildings.get("100 TEMP86")["display"].should == "Lothlorien Hall"
  end

  it "should look up 2224 PIEDMNT with a room number" do
    Buildings.get("100 2224 PIEDMNT")["display"].should == "2224 Piedmont"
  end

  it "should look up 2224 PIEDMNT without a room number" do
    Buildings.get("2224 PIEDMNT")["display"].should == "2224 Piedmont"
  end

  it "should return nil on a nonexistent building" do
    Buildings.get("Barad Dur").should be_nil
  end

end
