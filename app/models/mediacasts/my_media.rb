module Mediacasts
  class MyMedia < AbstractModel

    def initialize(options={})
      if options[:playlist_title]
        @playlist_title = options[:playlist_title]
        # Replace _slash_ with / since the front-end custom encodes slashes
        # We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
        if @playlist_title.include? '_slash_'
          @playlist_title.gsub!('_slash_', '/')
        end
      end
      super(@playlist_title, options)
    end

    def get_media_as_json
      playlist = get_playlist
      if !playlist[:proxy_error_message].blank? || !playlist[:body].blank?
        return {
          :proxyErrorMessage => playlist[:proxy_error_message] || playlist[:body]
        }
      end
      videos = get_videos_as_json(playlist)
      podcasts = get_podcasts_as_json(playlist)
      videos.merge(podcasts)
    end

    def get_videos_as_json(playlist)
      return {} unless Settings.features.videos
      if !playlist[:video_error_message].blank?
        return {
          :videoErrorMessage => playlist[:video_error_message]
        }
      end
      get_youtube_videos(playlist[:playlist_id])
    end

    def get_podcasts_as_json(playlist)
      return {} unless Settings.features.podcasts
      if !playlist[:podcast_error_message].blank?
        return {
          :podcastErrorMessage => playlist[:podcast_error_message]
        }
      end
      {
        :podcast => 'https://itunes.apple.com/us/itunes-u/id' + playlist[:podcast_id]
      }
    end

    def get_playlist
      if @playlist_title
        Mediacasts::Playlists.new({:playlist_title => @playlist_title}).get
      end
    end

    def get_youtube_videos(id)
      Mediacasts::Youtube.new({:playlist_id => id}).get
    end

  end
end
