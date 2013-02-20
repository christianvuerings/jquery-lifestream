require "spec_helper"

describe CalLinkProxy do

  before do
    @client = CalLinkProxy.new
  end

  it "should get the membership feed from CalLink" do
    data = @client.get_memberships "300846"
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["items"].should_not be_nil
    end
  end

end
