require "spec_helper"

describe SakaiProxy do

  it "should get the categorized sites from bspace" do
    data = SakaiProxy.get_categorized_sites "2040"
    data["principal"].should_not == nil
  end

  it "should get the unread sites from bspace" do
    data = SakaiProxy.get_unread_sites "2040"
    data["principal"].should_not == nil
  end

end
