require "spec_helper"

describe SakaiProxy do

  before do
    @client = SakaiProxy.new
  end

  it "should get the categorized sites from bspace" do
    data = @client.get_categorized_sites "300939"
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["principal"].should_not be_nil
    end
  end

  it "should get the unread sites from bspace" do
    data = @client.get_unread_sites "300939"
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["principal"].should_not be_nil
    end
  end

  it "should pass through errors while connecting to bspace" do
    bad_client = SakaiProxy.new(fake: false)
    stub_request(:any, "#{Settings.sakai_proxy.host}/sakai-hybrid/sites?unread=true").to_timeout
    data = bad_client.get_unread_sites "300939"
    data[:status_code].should == 503
    data[:body].should == "Remote server unreachable"
    WebMock.reset!
  end

  it "should make sure there are project or 'other' sites from the bSpace proxy (for groups)" do
    data = @client.get_categorized_sites "300939"
    data[:status_code].should_not be_nil
    if data[:status_code] == 200 && data[:body]["categories"] != nil
      if !data[:body]["categories"].empty?
        non_course_categories = data[:body]["categories"].select do |category|
          category["category"] =~ (/(projects|other)$/i)
        end
        # if a non_course_category shows, it should have some sites listed underneath.
        if non_course_categories.size != 0
          non_course_categories.each do |bspace_group|
            bspace_group["sites"].size.should_not == 0
          end
        end
      end

    end
end

end
