require "spec_helper"

describe CalLinkOrganizationProxy do

  it "should get the fake org feed from CalLink" do
    client = CalLinkOrganizationProxy.new({:org_id => "46085", :fake => true})
    data = client.get_organization
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["items"].should_not be_nil
      data[:body]["items"][0]["name"].should == "Theater Rice"
    end
  end

  it "should get the real org feed from CalLink", :testext => true do
    client = CalLinkOrganizationProxy.new({:org_id => "46085", :fake => false})
    data = client.get_organization
    data[:status_code].should == 200
    data[:body].should_not be_nil
  end

end
