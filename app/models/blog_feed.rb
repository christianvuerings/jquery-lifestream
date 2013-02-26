class BlogFeed < BaseProxy

  def initialize(options = {})
    super(Settings.blog_feed_proxy, options)
  end

  def get_release_notes
    Rails.cache.fetch(
      self.class.global_cache_key,
        :expires_in => Settings.cache.api_expires_in,
        :race_condition_ttl => 2.seconds
        ) do

      # Feed is fetched on server start, then updated in cache at standard interval
      Rails.logger.info "Fetching release notes from blog"

      release_notes = {}
      doc = Nokogiri::XML(open(Settings.blog_feed_proxy.feed_url))
      @entry = doc.xpath('//item').first

      # Process pub date string
      ds = @entry.xpath('pubDate').text
      d = Date.parse(ds)

      # Process and strip description
      @snippet = @entry.xpath('description').text
      @snippet = Nokogiri::HTML(@snippet).text # To strip all HTML tags, first convert to Nokogiri HTML node
      @snippet = @snippet.gsub!( /read more$/, "" ) # Trim off text appended to description by Drupal

      # release_notes array used directly in Splash template; not in API
      release_notes["title"] = @entry.xpath('title').text
      release_notes["link"] = @entry.xpath('link').text
      release_notes["date"] = d.strftime("%b %d")
      release_notes["snippet"] = @snippet

      release_notes
    end
  end
end
