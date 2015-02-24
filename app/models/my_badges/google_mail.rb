module MyBadges
  class GoogleMail
    include MyBadges::BadgesModule, DatedFeed, ClassLogger
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid
      @max_entries = 25
    end

    def fetch_counts(params = {})
      @google_mail ||= User::Oauth2Data.get_google_email(@uid)
      @rewrite_url ||= !(Mail::Address.new(@google_mail).domain =~ /berkeley.edu/).nil?
      self.class.fetch_from_cache(@uid) do
        internal_fetch_counts params
      end
    end

    private

    def internal_fetch_counts(params = {})
      google_proxy = GoogleApps::MailList.new(user_id: @uid)
      google_mail_results = google_proxy.mail_unread
      logger.debug "Processing GMail XML results: #{google_mail_results.inspect}"
      parse_feed google_mail_results
    end

    def parse_feed(google_mail_results)
      count = 0
      items = []
      begin
        if google_mail_results && google_mail_results.response && google_mail_results.response.status == 200
          feed = FeedWrapper.new MultiXml.parse(google_mail_results.response.body)
          count = feed['feed']['fullcount'].to_i
          items = feed['feed']['entry'].as_collection.each_with_index.map do |entry, index|
            break if index == @max_entries
            {
              editor: entry['author']['name'].to_text,
              link: 'http://bmail.berkeley.edu/',
              modifiedTime: format_date(entry['modified'].to_date),
              summary: entry['summary'].to_text,
              title: entry['title'].to_text
            }
          end
        end
      rescue => e
        logger.fatal "Error parsing XML output for GoogleApps::MailList: #{e}"
        logger.debug "Full dump of xml: #{google_mail_results.response.body}"
      end
      {
        count: count,
        items: items
      }
    end

  end
end
