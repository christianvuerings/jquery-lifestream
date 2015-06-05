module EtsBlog
  class Alerts < BaseProxy

    include DatedFeed
    include Proxies::HttpClient
    include Proxies::MockableXml

    def initialize(options = {})
      super(Settings.app_alerts_proxy, options)
      initialize_mocks if @fake
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
      #HTTParty won't parse automatically because the application/xml header is missing
      MultiXml.parse(get_response(@settings.base_url).body)
    end

    def mock_xml
      read_file('fixtures', 'xml', 'app_alerts_feed.xml')
    end

  end
end
