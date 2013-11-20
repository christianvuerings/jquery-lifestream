require "spec_helper"

describe "TextbooksProxy" do

  it "should get real textbook feed for valid ccns and slug", :testext => true do
    @ccns = ["41623"]
    @slug = "fall-2013"
    feed = {}
    proxy = TextbooksProxy.new({:ccns => @ccns, :slug => @slug, :fake => false})
    proxy_response = proxy.get
    proxy_response[:status_code].should_not be_nil
    if proxy_response[:status_code] == 200
      feed = proxy_response[:body]
      feed.should_not be_nil
      feed[:has_books].should be_true
      feed[:required_books][:books][0][:title] === 'Basic Statistics'
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
      feed = proxy_response[:body]
      feed.should_not be_nil
      feed[:has_books].should be_false
    end
  end

end
