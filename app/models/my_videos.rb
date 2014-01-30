class MyVideos < MyMergedModel

  def initialize(options={})
    @playlist_title = options[:playlist_title] ? options[:playlist_title] : false
  end

  def get_videos_as_json
    return {} unless Settings.features.videos
    self.class.fetch_from_cache "json-#{@playlist_title}" do
      playlist = get_playlist
      if !playlist[:error_message].blank?
        return playlist
      end
      get_youtube_videos(playlist[:playlist_id])
    end
  end

  def get_playlist
    if @playlist_title
      MyPlaylists.new(:playlist_title => @playlist_title).get_playlists_as_json
    end
  end

  def get_youtube_videos(id)
    MyYoutube.new(:playlist_id => id).get_videos_as_json
  end

end
