require "spec_helper"

describe CalLink::Organization do

  it "should get the fake org feed from CalLink" do
    client = CalLink::Organization.new({:org_id => "65797", :fake => true})
    data = client.get_organization
    data[:statusCode].should_not be_nil
    if data[:statusCode] == 200
      data[:body]["items"].should_not be_nil
      data[:body]["items"][0]["name"].should == "Bears Ice Hockey"
    end
  end

  it "should get the real org feed from CalLink", :testext => true do
    client = CalLink::Organization.new({:org_id => "65797", :fake => false})
    data = client.get_organization
    data[:statusCode].should == 200
    data[:body].should_not be_nil
  end

  it_should_behave_like 'a proxy logging errors' do
    subject { CalLink::Organization.new(org_id: '65797', fake: false).get_organization }
  end

end
