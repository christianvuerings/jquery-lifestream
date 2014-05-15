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
      podcasts = get_podcasts_as_json(playlist)
      videos.merge(podcasts)
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

    def get_youtube_videos(id)
      Mediacasts::Youtube.new({:playlist_id => id}).get
    end

  end
end
