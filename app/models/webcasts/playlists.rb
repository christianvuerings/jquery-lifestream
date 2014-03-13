module Webcasts
  class Playlists < BaseProxy

    include ClassLogger, SafeJsonParser

    APP_ID = "Playlists"

    def initialize(options = {})
      super(Settings.playlists_proxy, options)
      @playlist_title = options[:playlist_title] ? options[:playlist_title] : false
    end

    def get
      self.class.smart_fetch_from_cache(
        {id: @playlist_title,
         user_message_on_exception: "There was a problem fetching the videos."}) do
        request_internal
      end
    end

    def request_internal
      return {} unless Settings.features.videos
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
                {
                  :error_message => 'There was a problem fetching the videos.'
                })
      end

      logger.debug "Remote server status #{response.status}, Body = #{response.body}"

      data = convert_to_json(response)
      if !data
        raise Errors::ProxyError.new(
                "Error occurred converting response to json: #{response.body}",
                {
                  :error_message => 'There was a problem fetching the videos.'
                })
      end

      # If no playlist title is supplied, return full list of playlists
      if !@playlist_title
        return data
      end

      get_playlist_id(data)
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

    def get_playlist_id(data)
      title = @playlist_title
      courses = data['itu_courses']
      courses.each do |course|
        # Make sure the titles match and the playlist_id exists
        if course['title'].downcase == title.downcase && !course['youTube'].blank?
          return {
            :playlist_id => course['youTube']
          }
        end
      end
      {
        :error_message => "There are no videos available."
      }
    end

  end
end

