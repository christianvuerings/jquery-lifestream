module EtsBlog
  class RssProxy < BaseProxy
    include DatedFeed
    include Proxies::HttpClient
    include Proxies::MockableXml

    # Tell HTTParty that the 'application/rss+xml' content type used by Drupal should be parsed as XML.
    class RssParser < HTTParty::Parser
      SupportedFormats.merge!('application/rss+xml' => :xml)
    end

    def get_latest
      self.class.smart_fetch_from_cache(return_nil_on_generic_error: true) do
        get_feed_internal(@settings.base_url)
      end
    end

    def get_feed_internal(path)
      logger.info "Fetching #{path}; fake=#{@fake}; cache expiration #{self.class.expires_in}"
      response = get_response(path, {parser: RssParser})
      entries = Array.wrap(response['rss']['channel']['item'])
      if entries.present?
        entry = entries.first
        snippet = sanitize_html(entry['description'])
        snippet = snippet.squish.gsub(/ read more$/, '') if snippet.present?
        {
          title: entry['title'],
          link: entry['link'],
          timestamp: format_date(entry['pubDate'].to_datetime, '%b %d'),
          snippet: snippet
        }
      else
        nil
      end
    end

    def mock_response
      response = super
      response[:headers].merge!({'Content-Type' => 'application/rss+xml'})
      response
    end

  end
end
