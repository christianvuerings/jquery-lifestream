require "spec_helper"

describe CalLinkProxy do

  it "should get the fake membership feed from CalLink" do
    client = CalLinkProxy.new({:user_id => "300846", :fake => true})
    data = client.get_memberships
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["items"].should_not be_nil
    end
  end

  it "should get the real membership feed from CalLink", :testext => true do
    client = CalLinkProxy.new({:user_id => "300846", :fake => true})
    data = client.get_memberships
    data[:status_code].should == 200
    data[:body].should_not be_nil
  end

end
