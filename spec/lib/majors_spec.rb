require "spec_helper"

describe "Majors" do

  it "should look up a couple of real majors" do
    Majors.get("A A & ASIAN DIASPORA").should == "Asian American And Asian Diaspora Studies"
    Majors.get("BIOENG&MAT SCI&ENG").should == "Bioengineering And Materials Science And Engineering"
  end

  it "should return the untranslated name on a nonexistent majors" do
    Majors.get("URBAN ZOMBIE PACIFICATION STUDIES").should == "Urban Zombie Pacification Studies"
    Majors.get("double").should == "Double"
  end

end
