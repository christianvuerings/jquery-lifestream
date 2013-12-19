require 'json'

class MyYoutube < MyMergedModel

  def initialize(options={})
    @playlist_id = options[:playlist_id] ? options[:playlist_id] : false
    @my_videos = {
      :videos => []
    }
  end

  def get_videos_as_json
    return {} unless Settings.features.videos
    response = request
    if !response
      return @my_videos
    end
    filter_videos(response)
    @my_videos
  end

  def request()
    YoutubeProxy.new({:playlist_id => @playlist_id}).get
  end

  def filter_videos(response)
    data = JSON.parse(response[:body])
    entries = data['feed']['entry']
    entries.each do |entry|
      title = entry['media$group']['media$title']['$t']
      url = entry['media$group']['media$content'][0]['url']
      url.gsub!('/v/', '/embed/')
      link = url + '&showinfo=0&theme=light&modestbranding=1'
      @my_videos[:videos].push({
        :title => title,
        :link => link
      })
    end
  end

end
