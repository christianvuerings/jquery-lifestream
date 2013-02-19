class CalLinkProxy < BaseProxy

  require 'securerandom'

  APP_ID = "CalLink"

  def initialize(options = {})
    super(Settings.cal_link_proxy, options)
  end

  def do_get(uid)
    url = build_url uid
    Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url} on behalf of user #{uid}"
    begin
      response = FakeableProxy.wrap_request(APP_ID, @fake) {
        Faraday::Connection.new(
            :url => url
        ).get
      }
      if response.status >= 400
        Rails.logger.warn "#{self.class.name}: Connection failed: #{response.status} #{response.body}"
        return nil
      end
      Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
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

  private

  def build_url(uid)
    time = ( Time.now.utc.to_f * 1000).to_i
    random = SecureRandom.uuid
    prehash = "#{Settings.cal_link_proxy.public_key}#{time}#{random}#{Settings.cal_link_proxy.private_key}"

    hash = Digest::SHA256.hexdigest(prehash)
    Rails.logger.debug "#{self.class.name} prehash is #{prehash}"
    "#{Settings.cal_link_proxy.base_url}/api/memberships?username=#{uid}&apikey=#{Settings.cal_link_proxy.public_key}&time=#{time}&random=#{random}&hash=#{hash}"
  end

end
