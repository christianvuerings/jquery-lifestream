require "spec_helper"

describe CalLink::Memberships do

  it "should get the fake membership feed from CalLink" do
    client = CalLink::Memberships.new({:user_id => "300846", :fake => true})
    data = client.get_memberships
    data[:statusCode].should_not be_nil
    if data[:statusCode] == 200
      data[:body]["items"].should_not be_nil
    end
  end

  it "should get the real membership feed from CalLink", :testext => true do
    client = CalLink::Memberships.new({:user_id => "300846", :fake => false})
    data = client.get_memberships
    data[:statusCode].should == 200
    data[:body].should_not be_nil
  end

  it_should_behave_like 'a proxy logging errors' do
    let! (:uid) { 300846 }
    subject { CalLink::Memberships.new(user_id: uid, fake: false).get_memberships }
  end

end
