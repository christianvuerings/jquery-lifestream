module EtsBlog
  class ReleaseNotes < BaseProxy

    include ClassLogger, HtmlSanitizer
    include Proxies::MockableXml
    include HttpRequester

    def initialize(options = {})
      super(Settings.blog_latest_release_notes_feed_proxy, options)
      initialize_mocks if @fake
    end

    def default_message_on_exception
      'An error occurred retrieving release notes. Please try again later.'
    end

    def get_latest_release_notes
      self.class.fetch_from_cache do
        begin
          logger.info "Fetching release notes from blog, cache expiration #{self.class.expires_in}"
          #HTTParty won't parse automatically because the application/xml header is missing
          response = MultiXml.parse(get_response(@settings.base_url).body)
          entry = response['rss']['channel']['item'].first

          d = Date.parse entry['pubDate']
          # Clean up description and trim off text appended by Drupal
          snippet = sanitize_html(entry['description']).squish.gsub(/read more$/, '')

          {
            entries: [
              {
                title: entry['title'],
                link: entry['link'],
                date: d.strftime('%b %d'),
                snippet: snippet
              }]
          }
        rescue StandardError => e
          logger.error "Got an error fetching release notes: #{e.inspect}"
          {
            entries: []
          }
        end
      end
    end

    def mock_xml
      File.read(Rails.root.join('fixtures', 'xml', 'release_notes_feed.xml'))
    end

  end
end
