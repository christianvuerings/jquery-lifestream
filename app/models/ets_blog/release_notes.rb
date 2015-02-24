module EtsBlog
  class ReleaseNotes < BaseProxy

    include ClassLogger, HtmlSanitizer

    def initialize(options = {})
      super(Settings.blog_latest_release_notes_feed_proxy, options)
    end

    def get_latest_release_notes
      self.class.fetch_from_cache do
        begin
          logger.info "Fetching release notes from blog, cache expiration #{self.class.expires_in}"
          response = if @fake
                       MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'release_notes_feed.xml').to_s)
                     else
                       #HTTParty won't parse automatically because the application/xml header is missing
                       MultiXml.parse get_response(@settings.feed_url)
                     end
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
  end
end
