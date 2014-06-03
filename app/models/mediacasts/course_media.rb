module Mediacasts
  class CourseMedia < AbstractModel

    def self.course_id(year, term, dept, catalog_id)
      # allow lookups by either term_cd or term name
      term_cd = Berkeley::TermCodes.names[term.downcase]
      if term_cd.blank?
        term_cd = term
      end
      "#{year}-#{term_cd}-#{dept}-#{catalog_id}"
    end

    def initialize(year, term, dept, catalog_id)
      id = self.class.course_id(year, term, dept, catalog_id)
      super(id)
    end

    def get_feed
      playlist = get_playlist
      if !playlist[:proxy_error_message].blank? || !playlist[:body].blank?
        return {
          :proxyErrorMessage => playlist[:proxy_error_message] || playlist[:body]
        }
      end
      videos = get_videos_as_json(playlist)
      audio = get_audio_as_json(playlist)
      itunes = get_itunes_as_json(playlist)
      videos.merge(audio).merge(itunes)
    end

    def get_playlist
      proxy = Mediacasts::AllPlaylists.new
      all_playlists = proxy.get
      if all_playlists && all_playlists[:courses]
        playlist = all_playlists[:courses][@id]
        if playlist.blank?
          Mediacasts::AllPlaylists::ERRORS
        else
          playlist
        end
      else
        all_playlists
      end
    end

    def get_itunes_url(id)
      !id.blank? ? 'https://itunes.apple.com/us/itunes-u/id' + id : nil
    end

    def get_itunes_as_json(playlist)
      {
        :itunes => {
          :audio => get_itunes_url(playlist[:itunes_audio]),
          :video => get_itunes_url(playlist[:itunes_video])
        }
      }
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

    def get_audio_as_json(playlist)
      get_audio(playlist[:audio_rss])
    end

    def get_audio(audio_rss)
      Mediacasts::Audio.new({:audio_rss => audio_rss}).get
    end

    def get_youtube_videos(id)
      Mediacasts::Youtube.new({:playlist_id => id}).get
    end

  end
end
