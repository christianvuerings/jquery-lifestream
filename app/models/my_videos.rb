class MyVideos < SingleSourceModel

  def initialize(options={})
    if options[:playlist_title]
      @playlist_title = options[:playlist_title]
      # Replace _slash_ with / since the front-end custom encodes slashes
      # We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
      if @playlist_title.include? '_slash_'
        @playlist_title.gsub!('_slash_', '/')
      end
    end
  end

  def get_videos_as_json
    return {} unless Settings.features.videos
    playlist = get_playlist
    if !playlist[:error_message].blank?
      return playlist
    end
    get_youtube_videos(playlist[:playlist_id])
  end

  def get_playlist
    if @playlist_title
      PlaylistsProxy.new({:playlist_title => @playlist_title}).get
    end
  end

  def get_youtube_videos(id)
    YoutubeProxy.new({:playlist_id => id}).get
  end

end
