module Webcast
  class Audio < Proxy

    include ClassLogger, SafeJsonParser, DatedFeed

    APP_ID = 'Webcasts - Audio'

    def initialize(options = {})
      @audio_rss = options[:audio_rss]
    end

    def get
      self.class.smart_fetch_from_cache({id: @audio_rss}) do
        request_internal
      end
    end

    private

    def request_internal
      audio_items = []
      if Settings.features.audio && @audio_rss.present?
        begin
          response = get_response @audio_rss
          logger.debug "Remote server status #{response.code}, Body = #{response.body}"
          audio_items = filter_audio response if response && response.code < 400
        rescue => e
          logger.error "HTTP GET of Webcast audio RSS (#{@audio_rss}) failed: #{e.to_s}"
        end
      end
      {
        audio: audio_items
      }
    end

    def convert_to_https(url)
      url.sub('http://', 'https://')
    end

    def get_download_url(play_url)
      parsed_uri = Addressable::URI.parse play_url
      # Replace the path that starts with /media/
      parsed_uri.path = parsed_uri.path.sub(/^\/media\//, '/download/')
      parsed_uri.to_s
    end

    def filter_audio(response)
      rss = MultiXml.parse response.body
      lectures = rss['rss']['channel']['item']
      if lectures
        items = lectures.map do |i|
          # Older versions of the RSS have an empty link tag
          # so we need to use the enclosure tag instead
          url = convert_to_https(i['enclosure']['url'])
          title = i['title']
          title = title.first if title.is_a? Array
          {
            :downloadUrl => get_download_url(url),
            :playUrl => url,
            :title => title
          }
        end
        items.reverse
      else
        []
      end
    end

  end
end
