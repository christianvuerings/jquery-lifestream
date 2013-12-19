require "spec_helper"

describe MyYoutube do

  it "should filter videos properly", :testext => true do
    proxy = YoutubeProxy.new({:playlist_id => "-XXv-cvA_iCIEwJhyDVdyLMCiimv6Tup"})
    proxy_response = proxy.get
    subject.filter_videos(proxy_response)
    title = "Computer Science 61A - Lecture 1"
    link = "http://www.youtube.com/embed/JLkE4j6IrQA?version=3&f=playlists&app=youtube_gdata&showinfo=0&theme=light&modestbranding=1"
    expect(subject.instance_eval {@my_videos[:videos][0][:title]}).to eq title
    expect(subject.instance_eval {@my_videos[:videos][0][:link]}).to eq link
  end

end
