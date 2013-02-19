class SakaiProxy < BaseProxy
  extend Proxies::EnableForActAs

  APP_ID = "bSpace"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
  end

  def self.access_granted?
    settings = Settings.sakai_proxy
    settings.fake || (settings.host && settings.shared_secret)
  end

  def do_get(uid, url)
    Rails.cache.fetch(
        self.class.cache_key(uid),
        :expires_in => Settings.cache.api_expires_in,
        :race_condition_ttl => 2.seconds
    ) do
      token = build_token uid
      Rails.logger.info "SakaiProxy: Fake = #@fake; Making request to #{url} on behalf of user #{uid} with x-sakai-token = #{token}"
      begin
        response = FakeableProxy.wrap_request(APP_ID, @fake) {
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
