module EtsBlog
  class ServiceAlerts < RssProxy
    include ClassLogger
    include HtmlSanitizer

    def initialize(options = {})
      super(Settings.service_alerts_proxy, options)
      initialize_mocks if @fake
    end

    def default_message_on_exception
      'Alert server unreachable.'
    end

    def mock_xml
      read_file('fixtures', 'xml', 'service_alerts_feed.xml')
    end

  end
end
