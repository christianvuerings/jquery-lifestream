describe Berkeley::Majors do

  it "should look up a couple of real majors" do
    Berkeley::Majors.get("A A & ASIAN DIASPORA").should == "Asian American And Asian Diaspora Studies"
    Berkeley::Majors.get("BIOENG&MAT SCI&ENG").should == "Bioengineering And Materials Science And Engineering"
  end

  it "should return the untranslated name on a nonexistent majors" do
    Berkeley::Majors.get("URBAN ZOMBIE PACIFICATION STUDIES").should == "Urban Zombie Pacification Studies"
    Berkeley::Majors.get("double").should == "Double"
  end

end
