require 'spec_helper'

describe 'GoogleEventsList(recently_updated)' do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
  end

  it "should return a fake calendar list response for processing badges info on calendar feed" do
    proxy = GoogleEventsListProxy.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
    response_array = [
      proxy.recently_updated_items.first
    ]
    response_array.size.should == 1
    response_array[0].data["items"].size.should == 7
  end

end