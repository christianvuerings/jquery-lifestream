require 'json'

class MyYoutube < MyMergedModel

  include SafeJsonParser

  def initialize(options={})
    @playlist_id = options[:playlist_id] ? options[:playlist_id] : false
    @my_videos = {
      :videos => []
    }
  end

  def get_videos_as_json
    return {} unless Settings.features.videos
    self.class.fetch_from_cache "json-#{@playlist_id}" do
      response = request
      if !response
        return @my_videos
      end
      filter_videos(response)
      @my_videos
    end
  end

  def request()
    YoutubeProxy.new({:playlist_id => @playlist_id}).get
  end

  def filter_videos(response)
    data = safe_json(response[:body])
    return unless data && data['feed'] && data['feed']['entry']
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
