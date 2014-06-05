module Mediacasts
  class Youtube < BaseProxy

    include ClassLogger, SafeJsonParser

    APP_ID = "Youtube"

    def initialize(options = {})
      super(Settings.youtube_proxy, options)
      @playlist_id = options[:playlist_id]
      @url = @settings.base_url + @playlist_id
      @params = @settings.params.marshal_dump ? @settings.params.marshal_dump : {}
    end

    def get
      self.class.smart_fetch_from_cache({id: @playlist_id}) do
        request_internal
      end
    end

    private

    def request_internal(params = {})
      return {} unless Settings.features.videos
      response = FakeableProxy.wrap_request(APP_ID + "_" + "videos", @fake, {:match_requests_on => [:method, :path]}) {
        Faraday::Connection.new(
          :url => @url,
          :params => @params,
          :request => {
            :timeout => Settings.application.outgoing_http_timeout
          }
        ).get
      }
      if response.status >= 400
        raise Errors::ProxyError.new("Connection failed: #{response.status} #{response.body}")
      end

      logger.debug "Remote server status #{response.status}, Body = #{response.body}"
      {
        :videos => filter_videos(response)
      }
    end

    def filter_videos(response)
      videos = []
      data = safe_json(response.body)
      return videos unless data && data['feed'] && data['feed']['entry']
      entries = data['feed']['entry']
      entries.each do |entry|
        next unless entry['media$group']['media$title'] && entry['media$group']['media$content'] && entry['media$group']['media$content'][0]
        title = entry['media$group']['media$title']['$t']
        url = entry['media$group']['media$content'][0]['url']
        url.gsub!('/v/', '/embed/')
        link = url + '&showinfo=0&theme=light&modestbranding=1'
        id = link[link.index('embed/') + 6..link.index('?version') - 1]
        # Extract "Lecture x" from the title
        start1 = title.downcase.index('lecture')
        # Or extract date from title
        start2 = title.index(' - ')
        if start1
          lecture = title.slice(start1, title.length)
        elsif start2
          lecture = title.slice(start2 + 3, title.length)
        end
        videos.push({
                      :title => title,
                      :lecture => lecture || title,
                      :link => link,
                      :id => id
                    })
      end
      videos
    end

  end
end
