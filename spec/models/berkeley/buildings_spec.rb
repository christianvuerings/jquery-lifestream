require "spec_helper"

describe Berkeley::Buildings do

  it "should look up Hearst Mining" do
    Berkeley::Buildings.get("hearst min")["display"].should == "Hearst Memorial Mining Building"
  end

  it "should look up Lothlorien with a room number" do
    Berkeley::Buildings.get("100 TEMP86")["display"].should == "Lothlorien Hall"
    Berkeley::Buildings.get("100 TEMP86")["room_number"].should == "100"
  end

  it "should look up 2224 PIEDMNT with a room number" do
    Berkeley::Buildings.get("100 2224 PIEDMNT")["display"].should == "2224 Piedmont"
    Berkeley::Buildings.get("100 2224 PIEDMNT")["room_number"].should == "100"
  end

  it "should look up 2224 PIEDMNT without a room number" do
    Berkeley::Buildings.get("2224 PIEDMNT")["display"].should == "2224 Piedmont"
    Berkeley::Buildings.get("2224 PIEDMNT")["room_number"].should be_nil
  end

  it "should return nil on a nonexistent building" do
    Berkeley::Buildings.get("Barad Dur").should be_nil
  end

end
