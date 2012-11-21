require "spec_helper"

describe SakaiProxy do

  before do
    @client = SakaiProxy.new
  end

  it "should get the categorized sites from bspace" do
    data = @client.get_categorized_sites "2040"
    data[:status_code].should_not == nil
    if data[:status_code] == 200
      data[:body]["principal"].should_not == nil
    end
  end

  it "should get the unread sites from bspace" do
    data = @client.get_unread_sites "2040"
    data[:status_code].should_not == nil
    if data[:status_code] == 200
      data[:body]["principal"].should_not == nil
    end
  end

end
