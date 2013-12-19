require "spec_helper"
require "json"

describe YoutubeProxy do

  subject { YoutubeProxy.new({:playlist_id => "ECCF8E59B3C769FB01"}) }

  it "should get real youtube video data", :textext => true do
    proxy_response = subject.get
    expect(proxy_response[:status_code]).to eq 200
    response_body = proxy_response[:body]
    expect(response_body).not_to be_nil
    data = JSON.parse(response_body)
    expect(data["feed"]["title"]["$t"]).to eq "Biology 1A, 001 - Spring 2012"
  end

end
