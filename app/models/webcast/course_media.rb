module Webcast
  class CourseMedia

    def self.course_id(year, term, dept, catalog_id)
      # allow lookups by either term_cd or term name
      term_cd = Berkeley::TermCodes.names[term.downcase]
      if term_cd.blank?
        term_cd = term
      end
      "#{year}-#{term_cd}-#{dept}-#{catalog_id}"
    end

    def initialize(year, term, dept, catalog_id)
      dept = decode_slash(dept)
      catalog_id = decode_slash(catalog_id)
      @id = self.class.course_id(year, term, dept, catalog_id)
    end

    # Replaces '_slash_' with '/' since front-end encodes slashes. See CLC-4279.
    # We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
    def decode_slash(string)
      string.gsub('_slash_', '/')
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
      proxy = Webcast::Recordings.new
      recordings = proxy.get
      if recordings && recordings[:courses]
        playlist = recordings[:courses][@id]
        if playlist.blank?
          Webcast::Recordings::ERRORS
        else
          playlist
        end
      else
        recordings
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
      if !Settings.features.videos || playlist[:recordings].blank? || playlist[:audio_only]
        {
          :videos => []
        }
      else
        {
          :videos => playlist[:recordings].reverse
        }
      end
    end

    def get_audio_as_json(playlist)
      get_audio(playlist[:audio_rss])
    end

    def get_audio(audio_rss)
      Webcast::Audio.new({:audio_rss => audio_rss}).get
    end

  end
end
