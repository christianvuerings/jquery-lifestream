module EtsBlog
  class ReleaseNotes < BaseProxy

    include ClassLogger

    def initialize(options = {})
      super(Settings.blog_latest_release_notes_feed_proxy, options)
    end

    def get_latest_release_notes
      self.class.fetch_from_cache do
        logger.info "Fetching release notes from blog, cache expiration #{self.class.expires_in}"
        begin
          if @fake
            raw_xml = File.read(Rails.root.join('fixtures', 'xml', 'release_notes_feed.xml').to_s)
          else
            response = ActiveSupport::Notifications.instrument('proxy', {url: @settings.feed_url, class: self.class}) do
              HTTParty.get(
                @settings.feed_url,
                timeout: Settings.application.outgoing_http_timeout,
                verify: verify_ssl?
              )
            end
            raw_xml = response.body
          end

          doc = Nokogiri::XML(raw_xml)
          entry = doc.xpath('//item').first

          # Process pub date string
          ds = entry.xpath('pubDate').text
          d = Date.parse(ds)
          # Process and strip description
          snippet = entry.xpath('description').text
          snippet = Nokogiri::HTML(snippet).text # To strip all HTML tags, first convert to Nokogiri HTML node
          snippet = snippet.gsub(/read more$/, '') # Trim off text appended to description by Drupal
          snippet = snippet.gsub(/\n/, '')
          {
            entries: [
              {
                title: entry.xpath('title').text,
                link: entry.xpath('link').text,
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
