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
      response = ActiveSupport::Notifications.instrument('proxy', { url: @audio_rss, class: self.class }) do
        Faraday::Connection.new(
          :url => @audio_rss,
          :request => {
            :timeout => Settings.application.outgoing_http_timeout
          }
        ).get
      end
      if response.status >= 400
        raise Errors::ProxyError.new("Connection failed: #{response.status} #{response.body}")
      end
      logger.debug "Remote server status #{response.status}, Body = #{response.body}"
      {
        :audio => filter_audio(response.body)
      }
    end

    def get_parsed_pub_date(pub_date)
      date_time = DateTime.parse(pub_date)
      format_date(date_time)
    end

    def filter_audio(response)
      doc = Nokogiri::XML(response, &:strict)
      items = doc.xpath('//item').map do |i|
        {
          :date => get_parsed_pub_date(i.xpath('pubDate').text),
          # Older versions of the RSS have an empty link tag
          # so we need to use the enclosure tag instead
          :playUrl => i.xpath('enclosure/@url').text
        }
      end
      items
    end

  end
end
