module GoogleApps
  class MailList < Proxy

    include Proxies::MockableXml

    def mail_unread
      simple_request({http_method: :get, uri: Settings.google_proxy.atom_mail_feed_url, authenticated: true})
    end

    def mock_request
      super.merge(uri_matching: Settings.google_proxy.atom_mail_feed_url)
    end

    def mock_xml
      read_file('fixtures', 'xml', 'google_mail_list.xml')
    end

  end
end
