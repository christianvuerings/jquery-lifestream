require 'json'

class MyPlaylists < SingleSourceModel

  def initialize(options={})
    @playlist_title = options[:playlist_title] ? options[:playlist_title] : false
  end

  def get
    return {} unless Settings.features.videos
    PlaylistsProxy.new({:playlist_title => @playlist_title}).get
  end

end
