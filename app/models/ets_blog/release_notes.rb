module EtsBlog
  class ReleaseNotes < BaseProxy

    include ClassLogger

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
          snippet = ActionController::Base.helpers.strip_tags(entry['description'])
          snippet = CGI.unescape_html(snippet).gsub('&nbsp;', ' ') #unescape_html doesn't convert spaces
          snippet.squish!
          snippet.gsub!(/read more$/, '') # Trim off text appended to description by Drupal
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
