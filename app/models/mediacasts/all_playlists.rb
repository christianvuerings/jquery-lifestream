module Mediacasts
  class AllPlaylists < BaseProxy

    include ClassLogger, SafeJsonParser

    PROXY_ERROR = {
      :proxy_error_message => "There was a problem fetching the webcasts and podcasts."
    }

    ERRORS = {
      :video_error_message => "There are no webcasts available.",
      :podcast_error_message => "There are no podcasts available."
    }

    def initialize(options = {})
      super(Settings.playlists_warehouse_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache(
        {user_message_on_exception: PROXY_ERROR[:proxy_error_message]}) do
        request_internal
      end
    end

    private

    def request_internal
      return {} unless Settings.features.videos || Settings.features.podcasts
      if @fake
        logger.info "Fake = #@fake, getting data from JSON fixture file; cache expiration #{self.class.expires_in}"
        data = safe_json File.read(Rails.root.join('fixtures', 'json', 'webcasts.json').to_s)
      else
        response = HTTParty.get(
          @settings.base_url,
          basic_auth: {username: @settings.username, password: @settings.password},
          timeout: Settings.application.outgoing_http_timeout
        )
        if response.code >= 400
          raise Errors::ProxyError.new(
                  "Connection failed: #{response.code} #{response.body}",
                  PROXY_ERROR)
          logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        end
        data = safe_json response.body
      end

      if !data
        raise Errors::ProxyError.new(
                "Error occurred converting response to json: #{response.body}",
                PROXY_ERROR)
      end

      processed_playlists = {
        courses: {}
      }
      data['courses'].each do |course|
        if course['year'] && course['semester'] && course['deptName'] && course['catalogId']
          key = Mediacasts::CourseMedia.course_id(course['year'], course['semester'], course['deptName'], course['catalogId'])
          processed_playlists[:courses][key] = {
            playlist_id: course['youTubePlaylist'].to_s,
            podcast_id: course['iTunesAudio'].to_s
          }
          if course['youTubePlaylist'].blank?
            processed_playlists[:courses][key][:video_error_message] = ERRORS[:video_error_message]
          end
          if course['iTunesAudio'].blank?
            processed_playlists[:courses][key][:podcast_error_message] = ERRORS[:podcast_error_message]
          end
        end
      end

      processed_playlists
    end

  end
end

