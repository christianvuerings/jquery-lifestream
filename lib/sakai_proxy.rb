class SakaiProxy

  def self.get_categorized_sites(uid)
    url = "#{Settings.sakai_proxy.host}/sakai-hybrid/sites?categorized=true"
    do_get(uid, url)
  end

  def self.get_unread_sites(uid)
    url = "#{Settings.sakai_proxy.host}/sakai-hybrid/sites?unread=true"
    do_get(uid, url)
  end

  def self.do_get(uid, url)
    token = build_token uid
    Rails.logger.info "SakaiProxy: Making request to #{url} on behalf of user #{uid} with x-sakai-token = #{token}"
    response = Faraday::Connection.new(
        :url => url,
        :headers => {
            'x-sakai-token' => token
        }).get
    Rails.logger.debug "SakaiProxy response from remote server: #{response.body}"
    JSON.parse response.body
  end

  def self.build_token(uid)
    # the x-sakai-token format is defined here:
    # http://www.sakaiproject.org/blogs/lancespeelmon/x-sakai-token-authentication
    data = "#{uid};#{(Time.now.to_f * 1000).to_i.to_s}"
    encoded_data = Base64.encode64("#{OpenSSL::HMAC.digest(
        'sha1',
        Settings.sakai_proxy.shared_secret,
        data)}").rstrip
    token = "#{encoded_data};#{data}"
  end

end
