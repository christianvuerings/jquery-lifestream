require 'uri'
require 'base64'
require 'cgi'
require 'openssl'

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
    encoded_data = CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest(
        'sha1',
        Settings.sakai_proxy.shared_secret,
        uid + ";" + (Time.now.to_f * 1000).to_i.to_s)}\n"))
    Rails.logger.info "SakaiProxy: Making request on behalf of user #{uid} with x-sakai-token = #{encoded_data}"

    response = RestClient.get(url, {
        'x-sakai-token' => encoded_data
    })

    Rails.logger.debug "SakaiProxy response from remote server: #{response}"
    JSON.parse response.body
  end

end
