module Webcast
  class CourseMedia

    def self.id_per_ccn(year, term, ccn)
      term.to_s.strip!
      # Allow lookups by either term_cd or term name
      term_cd = Berkeley::TermCodes.names[term.downcase]
      "#{year}-#{term_cd || term.upcase}-#{ccn}"
    end

    def initialize(year, term, ccn_list, options = {})
      @year = year
      @term = term
      @ccn_list = ccn_list
      @options = options
    end

    # Replaces '_slash_' with '/' since front-end encodes slashes. See CLC-4279.
    # We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
    def decode_slash(string)
      string.gsub('_slash_', '/')
    end

    def get_feed
      return {} unless Settings.features.videos
      playlist_data_hash = get_playlist_hash
      error_message = playlist_data_hash[:proxy_error_message]
      unless error_message.blank? && playlist_data_hash[:body].blank?
        return {
          :proxyErrorMessage => error_message || playlist_data_hash[:body]
        }
      end
      feed = {}
      @ccn_list.each do |ccn|
        key = Webcast::CourseMedia.id_per_ccn(@year, @term, ccn)
        data = playlist_data_hash[ccn]
        if data
          videos = get_videos_as_json data
          audio = get_audio_as_json data
          itunes = get_itunes_as_json data
          feed[key] = videos.merge(audio).merge(itunes)
        else
          feed[key] = Webcast::Recordings::ERRORS
        end
      end
      feed
    end

    def get_playlist_hash
      playlist_hash = {}
      recordings = Webcast::Recordings.new(@options).get
      if recordings && recordings[:courses]
        @ccn_list.each do |ccn|
          key = Webcast::CourseMedia.id_per_ccn(@year, @term, ccn)
          playlist = recordings[:courses][key]
          playlist_hash[ccn] = playlist unless playlist.blank?
        end
      end
      playlist_hash
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
      if playlist[:recordings].blank? || playlist[:audio_only]
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
      get_audio playlist[:audio_rss]
    end

    def get_audio(audio_rss)
      audio_options = @options.merge({:audio_rss => audio_rss})
      Webcast::Audio.new(audio_options).get
    end

  end
end
