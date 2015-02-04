module EtsBlog
  class Alerts < BaseProxy

    include DatedFeed

    def initialize(options = {})
      super(Settings.app_alerts_proxy, options)
    end

    def get_latest
      self.class.smart_fetch_from_cache({
                                          id: "global-alert",
                                          user_message_on_exception: "Alert server unreachable",
                                          return_nil_on_generic_error: true
                                        }) do
        alerts = get_alerts
        alerts.empty? ? '' : alerts.first
      end
    end

    private

    def get_alerts
      feed = FeedWrapper.new get_feed
      logger.info("Unexpected data structure: #{feed.unwrap}") if feed['xml']['node'].blank?

      alerts = []
      feed['xml']['node'].as_collection.map do |node|
        alert = {
          title: node['Title'].to_text,
          url: node['Link'].to_text,
          timestamp: format_date(Time.zone.at(node['PostDate'].to_text.to_i).to_datetime)
        }
        alert[:teaser] = node['Teaser'] if node['Teaser'].present?
        if alert[:title].blank? || alert[:url].blank? || alert[:timestamp].blank? || alert[:timestamp][:epoch].zero?
          logger.error("Unexpected node in alert feed: #{node.unwrap}")
        else
          alerts << alert
        end
      end
      alerts
    end

    def get_feed
      logger.info "#{self.class.name} Fetching alerts from blog (fake=#{@fake}, cache expiration #{self.class.expires_in}"
      if @fake
        MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'app_alerts_feed.xml').to_s)
      else
        get_response(@settings.feed_url).parsed_response
      end
    end

  end
end
