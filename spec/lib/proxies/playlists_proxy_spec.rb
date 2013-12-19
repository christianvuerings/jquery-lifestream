require "spec_helper"

describe "PlaylistsProxy" do

  it "should get real courses data", :textext => true do
    proxy = PlaylistsProxy.new
    proxy_response = proxy.get
    expect(proxy_response[:status_code]).to eq 200
    courses = proxy_response[:body]
    expect(courses).not_to be_nil
  end

end
