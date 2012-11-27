class SakaiProxy < BaseProxy

  @@app_id = "sakai"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
  end

  def self.access_granted?
    settings = Settings.sakai_proxy
    settings.fake || (settings.host && settings.shared_secret)
  end

  def get_categorized_sites(uid)
    url = "#{@settings.host}/sakai-hybrid/sites?categorized=true"
    do_get(uid, url)
  end

  def get_unread_sites(uid)
    url = "#{@settings.host}/sakai-hybrid/sites?unread=true"
    do_get(uid, url)
  end

  def do_get(uid, url)
    token = build_token uid
    Rails.logger.info "SakaiProxy: Fake = #@fake; Making request to #{url} on behalf of user #{uid} with x-sakai-token = #{token}"
    begin
      response = FakeableProxy.wrap_request(@@app_id, @fake) {
        Faraday::Connection.new(
            :url => url,
            :headers => {
                'x-sakai-token' => token
            }).get
      }
      Rails.logger.debug "SakaiProxy - Remote server status #{response.status}, Body = #{response.body}"
      {
          :body => JSON.parse(response.body),
          :status_code => response.status
      }
    rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError
      {
          :body => "Remote server unreachable",
          :status_code => 503
      }
    end
  end

  def build_token(uid)
    # the x-sakai-token format is defined here:
    # http://www.sakaiproject.org/blogs/lancespeelmon/x-sakai-token-authentication
    data = "#{uid};#{(Time.now.to_f * 1000).to_i.to_s}"
    encoded_data = Base64.encode64("#{OpenSSL::HMAC.digest(
        'sha1',
        @settings.shared_secret,
        data)}").rstrip
    token = "#{encoded_data};#{data}"
  end

end
