module Mediacasts
  class Audio < BaseProxy

    include ClassLogger, SafeJsonParser, DatedFeed

    APP_ID = "Webcasts - Audio"

    def initialize(options = {})
      @audio_rss = options[:audio_rss]
    end

    def get
      self.class.smart_fetch_from_cache({id: @audio_rss}) do
        request_internal
      end
    end

    private

    def request_internal(params = {})
      if !Settings.features.audio || @audio_rss.blank?
        return {
          :audio => []
        }
      end
      response = get_response(@audio_rss)
      if response.code >= 400
        raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}")
      end
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      {
        :audio => filter_audio(response.body)
      }
    end

    def convert_to_https(url)
      url.sub('http://', 'https://')
    end

    def get_download_url(play_url)
      parsed_uri = Addressable::URI.parse(play_url)
      # Replace the path that starts with /media/
      parsed_uri.path = parsed_uri.path.sub(/^\/media\//, '/download/')
      parsed_uri.to_s
    end

    def filter_audio(response)
      doc = Nokogiri::XML(response, &:strict)
      items = doc.xpath('//item').map do |i|
        # Older versions of the RSS have an empty link tag
        # so we need to use the enclosure tag instead
        url = i.xpath('enclosure/@url').text
        url = convert_to_https(url)
        {
          :downloadUrl => get_download_url(url),
          :playUrl => url,
          :title => i.xpath('title').text
        }
      end
      items.reverse
    end

  end
end
