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
      self.class.fetch_from_cache do
        begin
          get_feed_internal(@settings.base_url)
        end
      end
    end

    def get_feed_internal(path)
      begin
        latest_entry = nil
        logger.info "Fetching #{path}; fake=#{@fake}; cache expiration #{self.class.expires_in}"
        response = get_response(path, {parser: RssParser})
        entries = response['rss']['channel']['item']
        if entries.present?
          entry = entries.first
          snippet = sanitize_html(entry['description']).squish.gsub(/read more$/, '')
          {
            title: entry['title'],
            link: entry['link'],
            timestamp: format_date(entry['pubDate'].to_datetime, '%b %d'),
            snippet: snippet
          }
        else
          nil
        end
      rescue StandardError => e
        logger.error "Got an error fetching release notes: #{e.inspect}"
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
