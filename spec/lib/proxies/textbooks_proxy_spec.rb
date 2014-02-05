require "spec_helper"

describe "TextbooksProxy" do

  it "should get real textbook feed for valid ccns and slug", :testext => true do
    @ccns = ["41575"]
    @slug = "spring-2014"
    feed = {}
    proxy = TextbooksProxy.new({:ccns => @ccns, :slug => @slug, :fake => false})
    proxy_response = proxy.get
    proxy_response[:status_code].should_not be_nil
    if proxy_response[:status_code] == 200
      feed = proxy_response[:books]
      feed.should_not be_nil
      feed[:has_books].should be_true
      expect(feed[:book_details][0][:books][0][:title]).to eq 'Observing the User Experience'
      feed[:book_details][0][:has_choices].should be_false
    end
  end

  it "should return false for has_books when either ccn or slug is invalid", :testext => true do
    @ccns = ['20764']
    @slug = 'fall-2011'
    feed = {}
    proxy = TextbooksProxy.new({:ccns => @ccns, :slug => @slug, :fake => false})
    proxy_response = proxy.get
    proxy_response[:status_code].should_not be_nil
    if proxy_response[:status_code] == 200
      feed = proxy_response
      feed.should_not be_nil
      feed[:has_books].should be_false
    end
  end

  it "should return true for has_choices when there are choices for a book", :testext => true do
    @ccns = ['73899']
    @slug = 'spring-2014'
    feed = {}
    proxy = TextbooksProxy.new({:ccns => @ccns, :slug => @slug, :fake => false})
    proxy_response = proxy.get
    proxy_response[:status_code].should_not be_nil
    if proxy_response[:status_code] == 200
      feed = proxy_response[:books]
      feed.should_not be_nil
      feed[:has_books].should be_true
      feed[:book_details][0][:has_choices].should be_true
    end
  end

  it "should return the actual error message returned by the bookstore when textbook information is unavailable", :testext => true do
    @ccns = ["09259"]
    @slug = "spring-2014"
    feed = {}
    proxy = TextbooksProxy.new({:ccns => @ccns, :slug => @slug, :fake => false})
    proxy_response = proxy.get
    proxy_response[:status_code].should_not be_nil
    if proxy_response[:status_code] == 200
      feed = proxy_response[:books]
      feed.should_not be_nil
      expect(feed[:book_unavailable_error]).to eq 'We are unable to find the specified course.'
    end
  end
end
