require "spec_helper"

describe Canvas::Groups do

  it "should get groups as known member" do
    client = Canvas::Groups.new(:user_id => @user_id)
    groups = client.groups
    groups.size.should > 0
    groups[0]['name'].should_not be_nil
  end


end
