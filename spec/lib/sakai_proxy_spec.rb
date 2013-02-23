require "spec_helper"

describe SakaiProxy do

  before do
    @client = SakaiProxy.new({:user_id => "300939"})
  end

  it "should get the categorized sites from bSpace" do
    data = @client.get_categorized_sites
    data[:status_code].should_not be_nil
    if data[:status_code] == 200
      data[:body]["principal"].should_not be_nil
    end
  end

  it "should pass through timeout errors while connecting to bSpace" do
    bad_client = SakaiProxy.new({:user_id => @uid, :fake => false})
    stub_request(:any, "#{Settings.sakai_proxy.host}/sakai-hybrid/sites?categorized=true").to_timeout
    data = {}
    suppress_rails_logging do
      data = bad_client.get_categorized_sites
    end
    data[:status_code].should == 503
    data[:body].should == "Remote server unreachable"
    WebMock.reset!
  end

  it "should pass through 503 errors while connecting to bSpace" do
    bad_client = SakaiProxy.new({:user_id => @uid, :fake => false})
    stub_request(:any, "#{Settings.sakai_proxy.host}/sakai-hybrid/sites?categorized=true").to_return(
        status: 503,
        body: '<?xml version="1.0" encoding="ISO-8859-1"?>'
    )
    data = {}
    suppress_rails_logging do
      data = bad_client.get_categorized_sites
    end
    data[:status_code].should == 503
    WebMock.reset!
  end

  it "should make sure there are project or 'other' sites from the bSpace proxy (for groups)" do
    data = @client.get_categorized_sites
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
