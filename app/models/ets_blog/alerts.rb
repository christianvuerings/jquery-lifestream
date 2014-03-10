module EtsBlog
  class Alerts < BaseProxy

    include DatedFeed
    require 'open-uri'

    def initialize(options = {})
      super(Settings.app_alerts_proxy, options)
    end

    def get_latest
      self.class.smart_fetch_from_cache({
                                          id: "global-alert",
                                          user_message_on_exception: "Alert server unreachable",
                                          return_nil_on_generic_error: true,
                                        }) do
        (get_alerts.nil?) ? nil : get_alerts.first
      end
    end

    private

    def get_alerts
      results = []
      xml = get_raw_xml
      doc = Nokogiri::XML(xml, &:strict)
      nodes = doc.css('node')
      nodes.each do |node|
        timestamp = node.css('PostDate').text.to_i
        result = {
          title: node.css('Title').text,
          teaser: node.css('Teaser').text,
          url: node.css('Link').text,
          timestamp: format_date(Time.zone.at(timestamp).to_datetime),
        }
        next unless valid_result?(result)
        results << result
      end
      (results.empty?) ? nil : results
    end

    def get_raw_xml
      logger.info "#{self.class.name} Fetching alerts from blog (fake=#{@fake}, cache expiration #{self.class.expires_in}"
      if @fake == true
        xml = File.read(xml_source)
      else
        xml = open(xml_source).base_uri.read
      end
    end

    def xml_source
      url ||= (@fake) ? Rails.root.join('fixtures', 'xml', 'app_alerts_feed.xml').to_s : @settings.feed_url
    end

    def valid_result?(r=nil)
      valid = true
      valid = false unless r.is_a?(Hash)
      [:title, :teaser, :url, :timestamp].each { |k|
        if !r.key?(k) || r[k].empty?
          valid = false
          break
        end
      }
      valid = false unless ((r[:timestamp].is_a?(Hash) && r[:timestamp][:epoch] > 0))
      logger.error("Unexpected result - #{r.inspect}") unless valid
      valid
    end
  end
end
