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
        result = {
          title: node.css('Title').text,
          url: node.css('Link').text,
          timestamp: format_date(Time.zone.at(node.css('PostDate').text.to_i).to_datetime),
        }
        result[:teaser] =  node.css('Teaser').text if node.css('Teaser').present?
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
      unless r.is_a?(Hash)
        logger.error("expected a hash argument #{r.inspect}")
        return false
      end
      [:title, :url, :timestamp].each { |k|
        unless r.key?(k) && r[k].present?
          logger.error("missing required #{k} field for hash argument #{r.inspect}")
          return false
        end
      }
      unless ((r[:timestamp].is_a?(Hash) && r[:timestamp][:epoch] > 0))
        logger.error("unexpected timestamp value #{r.inspect}")
        return false
      end
      return true
    end

  end
end
