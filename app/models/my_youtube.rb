require 'json'

class MyYoutube < SingleSourceModel

  include SafeJsonParser

  def initialize(options={})
    @playlist_id = options[:playlist_id] ? options[:playlist_id] : false
  end

  def get_feed_as_json
    return {} unless Settings.features.videos
    YoutubeProxy.new({:playlist_id => @playlist_id}).get
  end

end
