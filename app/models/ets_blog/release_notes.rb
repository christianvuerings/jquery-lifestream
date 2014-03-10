module EtsBlog
  class ReleaseNotes < BaseProxy

    def initialize(options = {})
      super(Settings.blog_latest_release_notes_feed_proxy, options)
    end

    def get_latest_release_notes
      self.class.fetch_from_cache do

        # Feed is fetched on server start, then updated in cache at standard interval
        Rails.logger.info "#{self.class.name} Fetching release notes from blog, cache expiration #{self.class.expires_in}"

        require 'open-uri'

        response = {
          :entries => []
        }

        doc = Nokogiri::XML(open(Settings.blog_latest_release_notes_feed_proxy.feed_url))
        entry = doc.xpath('//item').first

        # Process pub date string
        ds = entry.xpath('pubDate').text
        d = Date.parse(ds)

        # Process and strip description
        snippet = entry.xpath('description').text
        snippet = Nokogiri::HTML(snippet).text # To strip all HTML tags, first convert to Nokogiri HTML node
        snippet = snippet.gsub(/read more$/, "") # Trim off text appended to description by Drupal
        snippet = snippet.gsub(/\n/, "")
        response[:entries].push({
                                  title: entry.xpath('title').text,
                                  link: entry.xpath('link').text,
                                  date: d.strftime("%b %d"),
                                  snippet: snippet
                                })

        response
      end
    end
  end
end
