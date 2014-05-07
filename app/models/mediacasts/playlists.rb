module Mediacasts
  class Playlists < BaseProxy

    include ClassLogger, SafeJsonParser

    APP_ID = "Playlists"
    ERRORS = {
      :video_error_message => "There are no webcasts available.",
      :podcast_error_message => "There are no podcasts available."
    }
    PROXY_ERROR = {
      :proxy_error_message => "There was a problem fetching the webcasts and podcasts."
    }

    def initialize(options = {})
      super(Settings.playlists_proxy, options)
      @playlist_title = options[:playlist_title] ? options[:playlist_title] : false
    end

    def get
      self.class.smart_fetch_from_cache(
        {id: @playlist_title,
         user_message_on_exception: PROXY_ERROR[:proxy_error_message]}) do
        request_internal
      end
    end

    def request_internal
      return {} unless Settings.features.videos || Settings.features.podcasts
      response = FakeableProxy.wrap_request(APP_ID + "_" + "playlists", @fake, {:match_requests_on => [:method, :path]}) {
        Faraday::Connection.new(
          :url => @settings.base_url,
          :params => @params,
          :request => {
            :timeout => Settings.application.outgoing_http_timeout
          }
        ).get
      }
      if response.status >= 400
        raise Errors::ProxyError.new(
                "Connection failed: #{response.status} #{response.body}",
                PROXY_ERROR)
      end

      logger.debug "Remote server status #{response.status}, Body = #{response.body}"

      data = convert_to_json(response)
      if !data
        raise Errors::ProxyError.new(
                "Error occurred converting response to json: #{response.body}",
                PROXY_ERROR)
      end

      # If no playlist title is supplied, return full list of playlists
      if !@playlist_title
        return data
      end

      get_playlist_info(data)
    end

    def convert_to_json(response)
      data = response.body
      cut_index = data.index('itu_courses')
      # Extract the itu_courses array
      js = data.slice(cut_index..-1)
      # Format to valid JSON
      replacements =
        [
          [' =', ':'],
          ['itu_courses', '"itu_courses"'],
          [';', ''],
          ['//', ''],
          [/\t/, '']
        ]
      replacements.each { |replacement| js.gsub!(replacement[0], replacement[1]) }
      # Strip trailing commas if they exist
      if js.rindex(',') == js.rindex('}') + 1
        js.slice!(js.rindex(','))
      end
      json = '{' + js + '}'
      safe_json(json)
    rescue => e
      puts "There was an issue parsing the data: #{e.message}"
      return false
    end

    def get_playlist_info(data)
      title = @playlist_title
      courses = data['itu_courses']
      courses.each do |course|
        # Make sure the titles match and the playlist_id exists
        if course['title'].downcase == title.downcase
          playlist = {}
          if !course['youTube'].blank?
            playlist[:playlist_id] = course['youTube']
          else
            playlist[:video_error_message] = ERRORS[:video_error_message]
          end
          if !course['audioId'].blank?
            playlist[:podcast_id] = course['audioId']
          else
            playlist[:podcast_error_message] = ERRORS[:podcast_error_message]
          end
          return playlist
        end
      end
      ERRORS
    end

  end
end

