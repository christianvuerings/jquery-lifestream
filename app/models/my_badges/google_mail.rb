class MyBadges::GoogleMail
  include MyBadges::BadgesModule

  def initialize(uid)
    @uid = uid
  end

  def fetch_counts(params = {})
    self.class.fetch_from_cache(@uid) do
      internal_fetch_counts params
    end
  end

  private

  def internal_fetch_counts(params = {})
    google_proxy = GoogleMailListProxy.new(user_id: @uid)
    google_mail_results = google_proxy.mail_unread
    Rails.logger.debug "Processing #{google_mail_results} GMail XML results"

    begin
      if google_mail_results && google_mail_results.response
        response = Nokogiri::XML.parse(google_mail_results.response.body)
        unread_count = response.search('fullcount').first.content.to_i
      end
    rescue Exception => e
      Rails.logger.fatal "Error parsing XML output from GoogleMailListProxy: #{e}"
    end
    unread_count ||= 0
  end

end
